class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Item, collection: { id: (user ? user.collection_ids : []) }
    can :read, Item
  end
end
