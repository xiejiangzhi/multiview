module Multiview
  class Manager
    attr_reader :versions_map

    # Params:
    #   config: {controller_path: version
    def initialize(versions_map)
      @versions_map = versions_map.symbolize_keys
    end

    def dispatch(env, controller_path, action_name, version = nil)
      version ||= find_version(controller_path)
      return if version.nil?

      class_name = "#{version}/#{controller_path}_controller".camelize
      ctrl_cls = class_name.safe_constantize
      new_action_name = "#{class_name}##{action_name}"
      env['multiview'] = {version: version}.with_indifferent_access

      if ctrl_cls && ctrl_cls.public_method_defined?(action_name)
        Rails.logger.debug("[Multiview] Dispatch to #{new_action_name}")
        action_block = ctrl_cls.action(action_name)
        action_block.call(env)
      else
        Rails.logger.warn("[Multiview] Not found #{new_action_name}")
        nil
      end
    end

    def redispatch(controller, controller_path = nil, action_name = nil, version = nil)
      controller_path ||= controller.params[:controller]
      action_name ||= controller.params[:action]
      version ||= find_version(controller_path)
      return unless version

      result = try_dispatch(controller.request.env, controller_path, action_name, version)
      if result
        res = controller.response
        status, headers, body = result
        res.status = status
        res.header.clear
        res.header.merge!(headers)
        controller.response_body = body
      else
        # no action, just use views
        load_version_view(controller, version)
      end
    end

    def find_version(path)
      versions_map[path.to_sym]
    end


    private

    def load_version_view(controller, version)
      return if version.to_sym == :v1
      Rails.logger.warn("[Multiview] Prepend view path app/views/#{version}")
      controller.prepend_view_path(Rails.root.join("app/views/#{version}"))
    end

    def try_dispatch(env, path, action, version)
      return if env['multiview']
      dispatch(env, path, action, version)
    end
  end
end
