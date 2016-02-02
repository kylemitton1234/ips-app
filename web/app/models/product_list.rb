class ProductList < ActiveRecord::Base
  belongs_to :deal
  belongs_to :listable, polymorphic: true
  has_many :products, autosave: true, dependent: :destroy
  has_many :insurance_policies, autosave: true, dependent: :destroy

  validates :car_profit_cents, :family_profit_cents, :insurance_profit, numericality: { greater_than_or_equal_to: 0 }

  accepts_nested_attributes_for :products, allow_destroy: true
  accepts_nested_attributes_for :insurance_policies, allow_destroy: true
  accepts_nested_attributes_for :deal

  after_initialize :set_defaults

  monetize :car_profit_cents, :family_profit_cents

  private

  def set_defaults
    #dollars
    self.car_profit ||= 1000
    self.family_profit ||= 1000
    #percent
    self.insurance_profit ||= 40
  end
end