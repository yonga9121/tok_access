class TokAccessCreate<%= table_name.camelize %> < ActiveRecord::Migration<%= migration_version %>
  def change

    create_table :<%= table_name %> do |t|
      <%= migration_data %>
      <% attributes.each do |attribute| %>
        t.<%= attribute.type %> :<%= attribute.name %>
      <% end %>
    end
  end

end
