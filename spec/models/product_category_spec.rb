require 'rails_helper'

RSpec.describe ProductCategory, type: :model do

  let(:name)         { double :name }
  let(:product_list) { double :product_list, insurance_profit_rate: insurance_profit_rate }
  let(:lender)       { double :lender }

  let(:category) { described_class.new name: name, product_list: product_list, lender: lender }

  let(:insurance_profit_rate) { double :insurance_profit_rate }
  let(:money)                 { double :money }

  let(:products_collection)           { double :products_collection }
  let(:insurance_policies_collection) { double :insurance_policies_collection }
  let(:insurance_terms_collection)    { double :insurance_terms_collection }

  let(:insurance_policies_collection_grouped_by_name) { double :insurance_policies_collection_grouped_by_name }

  describe '#display_name' do
    subject { category.display_name }

    { 'pocketbook' => 'Pocketbook Protection', 'car' => 'Car Protection Kit', 'family' => 'Family Protection' }.each do |name, expected_display_name|
      context "when category is #{name}" do
        let(:name) { name }

        it { is_expected.to eq expected_display_name }
      end
    end
  end

  describe '#amount' do
    subject { category.amount }

    before do
      allow(category).to receive(:products_amount).and_return money
      allow(category).to receive(:insurance_amount).and_return money
      allow(money).to receive(:+).with(money).and_return money
    end

    it { is_expected.to eq money }
  end

  describe '#profit' do
    subject { category.profit }

    before do
      allow(category).to receive(:products_profit).and_return money
      allow(category).to receive(:insurance_profit).and_return money
      allow(money).to receive(:+).with(money).and_return money
    end

    it { is_expected.to eq money }
  end

  describe '#buy_down_amount' do
    subject { category.buy_down_amount }

    before do
      allow(category).to receive(:profit).and_return money
      allow(category).to receive(:reserved_profit).and_return money
      allow(money).to receive(:-).with(money).and_return money
    end
    it { is_expected.to eq money }
  end

  describe '#count' do
    subject { category.count }

    let(:count) { double :count }

    before do
      allow(category).to receive(:products).and_return products_collection
      allow(category).to receive(:insurance_terms).and_return insurance_terms_collection

      allow(products_collection).to receive(:count).and_return count
      allow(insurance_terms_collection).to receive(:count).and_return count
      allow(count).to receive(:+).and_return count
    end

    it { is_expected.to eq count }
  end

  describe '#available_count' do
    subject { category.available_count }

    let(:count) { double :count }

    before do
      allow(category).to receive(:available_products).and_return products_collection
      allow(category).to receive(:available_insurance_policies_count).and_return count

      allow(products_collection).to receive(:count).and_return count
      allow(insurance_terms_collection).to receive(:count).and_return count
      allow(count).to receive(:+).and_return count
    end

    it { is_expected.to eq count }
  end

  describe '#unselected_count' do
    subject { category.unselected_count }

    let(:count) { double :count }

    before do
      allow(category).to receive(:available_count).and_return count
      allow(category).to receive(:count).and_return count

      allow(count).to receive(:-).and_return count
    end

    it { is_expected.to eq count }
  end

  describe '#products' do
    subject { category.products }

    let(:products_collection) { double :products_collection }

    before do
      allow(lender).to receive(:products).and_return products_collection
      allow(products_collection).to receive(:where).with(category: name).and_return products_collection
    end

    it { is_expected.to eq products_collection }
  end

  describe '#available_products' do
    subject { category.available_products }

    let(:product_list) { double :product_list, products: products_collection }

    before do
      allow(products_collection).to receive(:visible).and_return products_collection
      allow(products_collection).to receive(:where).with(category: name).and_return products_collection
    end

    it { is_expected.to eq products_collection }
  end

  describe '#insurance_terms' do
    subject { category.insurance_terms }

    before do
      allow(lender).to receive(:insurance_terms).and_return insurance_terms_collection
      allow(insurance_terms_collection).to receive(:where).with(category: name).and_return insurance_terms_collection
    end

    it { is_expected.to eq insurance_terms_collection }
  end

  describe '#available_insurance_policies' do
    subject { category.available_insurance_policies }

    let(:loan) { double :loan }

    before do
      allow(product_list).to receive(:insurance_policies).and_return insurance_policies_collection
      allow(lender).to receive(:loan).and_return loan
      expect(insurance_policies_collection).to receive(:where).with(category: name, loan: loan).and_return insurance_policies_collection
    end

    it { is_expected.to eq insurance_policies_collection }
  end

  describe '#available_insurance_policies_grouped_by_name' do
    subject { category.available_insurance_policies_grouped_by_name }

    before do
      allow(category).to receive(:available_insurance_policies).and_return insurance_policies_collection
      expect(insurance_policies_collection).to receive(:group_by).and_return insurance_policies_collection_grouped_by_name
    end

    it { is_expected.to eq insurance_policies_collection_grouped_by_name }
  end

  describe '#reserved_profit' do
    subject { category.send :reserved_profit }

    let(:pocketbook_reserved_profit) { double :pocketbook_reserved_profit }
    let(:car_reserved_profit)        { double :car_reserved_profit }
    let(:family_reserved_profit)     { double :family_reserved_profit }

    let(:money_class) { class_double('Money').as_stubbed_const }

    let(:tier) { double :tier }

    before do
      allow(category).to receive(:lender).and_return lender
      allow(category).to receive(:product_list).and_return product_list

      allow(money_class).to receive(:new).with(1_000_00).and_return money
      allow(lender).to receive(:tier).and_return tier
      allow(money).to receive(:*).with(tier).and_return pocketbook_reserved_profit

      allow(product_list).to receive(:car_reserved_profit).and_return car_reserved_profit
      allow(product_list).to receive(:family_reserved_profit).and_return family_reserved_profit
    end

    context 'when category is pocketbook' do
      let(:name) { 'pocketbook' }

      it { is_expected.to eq pocketbook_reserved_profit }
    end

    context 'when category is car' do
      let(:name) { 'car' }

      it { is_expected.to eq car_reserved_profit }
    end

    context 'when category is family' do
      let(:name) { 'family' }

      it { is_expected.to eq family_reserved_profit }
    end
  end

  describe '#products_amount' do
    subject { category.send :products_amount }

    let(:products_collection) { double :products_collection, amount: money }

    before do
      allow(category).to receive(:products).and_return products_collection
      allow(category).to receive(:invisible_products).and_return products_collection
      allow(money).to receive(:+).with(money).and_return money
    end

    it { is_expected.to eq money }
  end

  describe '#products_profit' do
    subject { category.send :products_profit }

    let(:products_collection) { double :products_collection, profit: money }

    before do
      allow(category).to receive(:products).and_return products_collection
      allow(category).to receive(:invisible_products).and_return products_collection
      allow(money).to receive(:+).with(money).and_return money
    end

    it { is_expected.to eq money }
  end

  describe '#insurance_amount' do
    subject { category.send :insurance_amount }

    before do
      allow(category).to receive(:insurance_terms).and_return insurance_terms_collection
      allow(category).to receive(:lender).and_return lender
      allow(lender).to receive(:insurable_amount).and_return money
      allow(insurance_terms_collection).to receive(:amount).with(money).and_return money
    end

    it { is_expected.to eq money }
  end

  describe '#insurance_profit' do
    subject { category.send :insurance_profit }

    before do
      allow(category).to receive(:insurance_amount).and_return money
      allow(category).to receive(:product_list).and_return product_list

      allow(money).to receive(:*).with(insurance_profit_rate).and_return money
    end

    it { is_expected.to eq money }
  end

  describe '#invisible_products' do
    subject { category.send :invisible_products }

    let(:products_collection) { double :products_collection }

    before do
      allow(lender).to receive(:invisible_products).and_return products_collection
      allow(products_collection).to receive(:where).with(category: name).and_return products_collection
    end

    it { is_expected.to eq products_collection }
  end

  describe '#available_insurance_policies_count' do
    subject { category.send :available_insurance_policies_count }

    let(:count) { double :count }

    before do
      allow(category).to receive(:available_insurance_policies_grouped_by_name).and_return insurance_policies_collection_grouped_by_name
      expect(insurance_policies_collection_grouped_by_name).to receive(:count).and_return count
    end

    it { is_expected.to eq count }
  end
end
