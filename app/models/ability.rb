class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Item
    can :manage, Item, collection: { id: (user ? user.collection_ids : []) }

    can :read, Entity
    # can :manage, [Entity] {|entity| user.collection_ids.include?(entity.item.collection_id)}
    can :manage, Entity, item: { collection: { id: (user ? user.collection_ids : []) }}
  end
end
