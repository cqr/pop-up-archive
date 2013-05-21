class Ability
  include CanCan::Ability

  def initialize(user)
    can :read,   Collection
    can :create, Collection
    can :manage, Collection, id: (user ? user.collection_ids : [])

    can :read,   Item
    can :manage, Item, collection: { id: (user ? user.collection_ids : []) }

    can :read,   Entity
    can :manage, Entity, item: { collection: { id: (user ? user.collection_ids : []) }}
    
    can :read,   Contribution
    can :manage, Contribution, item: { collection: { id: (user ? user.collection_ids : []) }}
  end
end
