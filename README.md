# Описание
__chrno_can_interact__ -- позволяет сохранять факты воздействия одного объекта на другой.
Удобно использовать для реализации всевозможных голосований, подписок и т.п.

## Пример использования:

Реализация голосовалки:

    rails g can_interact:install
    rake db:migrate
    ...
    class Comment
      can_interact :with => User,
        :actions   => [ :heal, :damage ],
        :only_once => Proc.new { |initiator, target| not initiator.admin? }

      after_heal do |user|
        comment.score += 1
        comment.save!
      end

      after_damage do |user|
        comment.score -= 1
        comment.save!
      end
    end
    ...
    comment.heal_by current_user
    comment.damage_by current_user