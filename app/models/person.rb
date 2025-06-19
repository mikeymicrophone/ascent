class Person < ApplicationRecord
  has_many :candidacies, dependent: :destroy
  has_many :elections, through: :candidacies
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  def full_name
    [first_name, middle_name, last_name].compact.join(' ')
  end
  
  def name
    full_name
  end
end
