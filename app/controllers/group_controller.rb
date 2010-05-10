class GroupController < ApplicationController

  def edit_group
    @group = Group.find_by_id(params[:id]) || Group.new

    if request.post?
      new_group = true if params[:id].nil?
      @group.attributes = params[:group]
      @group.addresses = (params[:included].blank? ? [] : Address.find(params[:included]))

      if @group.save
        @saved = true
      else
        logger.error("Edit group failed: #{@group.errors.full_messages}")
      end
    end

    @group_list = Group.find_for_list if new_group
    include_common_data
  end
  
  def delete_group
    @group = Group.find_by_id(params[:id])
    @group.ergo.destroy
    include_common_data
  end

  def create_labels
    @group = Group.find_by_id(params[:id])
    @group.create_labels(params[:label_type])
    redirect_to("/#{Group::LABELS_FILE}")
    include_common_data
  end
  
  private

    def get_not_included_addresses
      addresses = Address.find_all_eligible_for_group
      included_addresses = @group.addresses
      included_addresses.each { |a| addresses.delete(a) }
      addresses
    end

    def include_common_data
      @included = @group.addresses
      @not_included = get_not_included_addresses
      @label_types = Pdf::Label::Batch.all_template_names.sort!
    end

end
