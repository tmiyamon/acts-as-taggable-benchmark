class TaggableArrayUser < ActiveRecord::Base
  acts_as_taggable_array_on :skills
end
