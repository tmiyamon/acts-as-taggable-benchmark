class TaggableUser < ActiveRecord::Base
  acts_as_taggable_on :skills
end
