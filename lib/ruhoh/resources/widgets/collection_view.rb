module Ruhoh::Resources::Widgets
  class CollectionView < Ruhoh::Base::CollectionView

    def widget(name)
      page_config = (master.page_data["widgets"][name] || {}) rescue {}
      widget_config = (config[name] || {}).merge(page_config)
      return '' if widget_config['enable'].to_s == 'false'

      data = find_by_id("#{name}/#{(widget_config['use'] || "default")}.html")
      return '' unless data

      view = @ruhoh.master_view('')

      # merge the config.yml data into the inline layout data.
      # Note this is reversing the normal hierarchy 
      # in that inline should always override config level.
      # However the inline in this case is set as implementation defaults 
      # and meant to be overridden by user specific data.
      view.render(find(data['pointer']).content, {
        "this_config" => data.merge(widget_config),
        "this_path" => @ruhoh.to_url(url_endpoint, name)
      })
    end

    def method_missing(name, *args, &block)
      __getobj__.widgets.include?(name.to_s) ? widget(name.to_s) : super
    end

    def respond_to?(method)
      __getobj__.widgets.include?(method.to_s) ? true : super
    end

  end
end