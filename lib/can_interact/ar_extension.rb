# encoding: utf-8
require "active_record/callbacks"

module CanInteract
  # Расширения для ActiveRecord
  module ARExtension

    ##
    # Макрос can_interact позволяет сохранять в базе факты воздействий одного
    # объекта на другой.
    #
    # Возможные параметры:
    #   :with      - (обязательный) класс(ы) с которыми может взаимодействовать
    #                объект. Возможные значения: метод класса (символ), Proc,
    #                класс, массив классов, символ :any.
    #   :actions   - (обязательный) виды взаимодействий. Возможные значения:
    #                массив символов.
    #   :only_once - (по умолчанию false) объекты могут взаимодействовать не
    #                больше одного раза. Возможные значение: true, false, Proc,
    #                метод класса (символ).
    #
    # @example
    #   can_interact :with => User,
    #     :actions   => [ :heal, :damage ],
    #     :only_once => Proc.new { |initiator, target| not initiator.admin? }
    #
    def can_interact( options )
      options.assert_keys_presence :with, :actions

      # Настройки по умолчанию
      options[ :only_once ] ||= false

      # Нам нужны колбэки
      include ActiveSupport::Callbacks

      # Прицепляем интеракции
      has_many :interactions, as: :target,  dependent: :destroy,
        class_name: "CanInteract::Interaction"

      # Создаём обработчики
      actions = options.delete :actions
      actions.each { |action| setup_action( action, options ) }
    end

    private

    ##
    # Добавляет действие в класс.
    #
    # @param [#to_s] action название действия
    # @param [Hash] options параметры, переданные макросу {can_interact}
    #
    def setup_action( action, options )
      # Добавляем проверки и callback
      setup_initiator_check( action, options )
      setup_multiple_interactions_check( action, options )
      setup_callback( action, options)

      define_method "can_#{action}_by?" do |initiator|
        return false unless send( "#{action}_initiator_valid?", initiator )

        if send( "can_#{action}_only_once?", initiator )
          unless self.changed?
            not self.interactions.where( initiator_id: initiator.id, initiator_type: initiator.class.name ).any?
          else
            # Убрать в случае большого кол-ва интеракций
            not self.interactions.detect { |i| i.initiator == initiator }
          end
        else
          true
        end
      end

      define_method "#{action}_by" do |initiator, *params|
        params = params.first

        return false unless send( "can_#{action}_by?", initiator )

        self.interactions.build do |i|
          i.initiator = initiator
          i.action    = action.to_s
          i.params    = params
        end

        run_callbacks( action ) and true
      end
    end

    ##
    # Создаёт метод.
    #
    # @param [String, Symbol] name название метода
    # @param [Proc, Symbol] proc_or_symbol лямбда или название метода, который нужно вызвать
    #
    def define_check( name, proc_or_symbol )
      if proc_or_symbol.is_a? Symbol
        proc_or_symbol = Proc.new { |subject, initiator|
          subject.send( proc_or_symbol, initiator )
        }
      end

      define_method name do |initiator|
        proc_or_symbol.call self, initiator
      end
    end

    ##
    # Добавляет в класс проверки инициатора взаимодействия.
    #
    # @param [#to_s] action название действия
    # @param [Hash] options параметры, переданные макросу {can_interact}
    #
    def setup_initiator_check( action, options )
      with = options[ :with ]

      proc = case with
        when Proc
          with
        when Symbol
          with == :any ? Proc.new { true } : with
        when Class
          Proc.new { |target, initiator| initiator.is_a? with }
        when Array
          Proc.new { |target, initiator| with.include? initiator.class }
        else
          raise ArgumentError, %Q{
            invalid :with option. Expected: Proc, Symbol, Class or Array. Got: #{with.inspect}.
          }
      end

      define_check "#{action}_initiator_valid?", proc
    end

    ##
    # Добавляет в класс проверки на возможность повторного взаимодействия 2 объектов.
    #
    # @param [#to_s] action название действия
    # @param [Hash] options параметры, переданные макросу {can_interact}
    #
    def setup_multiple_interactions_check( action, options )
      only_once = options[ :only_once ]

      proc = case only_once
        when TrueClass, FalseClass
          Proc.new { only_once }
        when Proc, Symbol
          only_once
        else
          raise ArgumentError, %Q{
            invalid :only_once option. Expected: true, false or Proc. Got: #{only_once.inspect}.
          }
      end

      define_check "can_#{action}_only_once?", proc
    end

    ##
    # Добавляет колбэк в класс.
    #
    # @param [#to_s] action название действия
    # @param [Hash] options параметры, переданные макросу {can_interact}
    #
    def setup_callback( action, options )
      action = action.to_sym

      define_callbacks action

      # Используем этот хак вместо class << self для того чтобы иметь доступ
      # к локальным переменным метода (в данном случае нам нужен параметр action)
      ( class << self; self; end ).instance_eval do
       [ :before, :after ].each do |call_when|
         define_method "#{call_when}_#{action}" do |*args, &block|
           set_callback action, call_when, *args, &block
         end
       end
      end
    end
  end
end