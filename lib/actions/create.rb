module ActiveScaffold::Actions
  module Create
    include Base

    def self.included(base)
      super
      base.verify :method => :post,
                  :only => :create,
                  :redirect_to => { :action => :index }
    end

    def new
      insulate { do_new }

      respond_to do |type|
        type.html do
          if successful?
            render(:action => 'create_form', :layout => true)
          else
            return_to_main
          end
        end
        type.js do
          render(:partial => 'create_form', :layout => false)
        end
      end
    end

    def create
      insulate { do_create }

      respond_to do |type|
        type.html do
          if successful?
            flash[:info] = _('CREATED %s', @record.to_label)
            return_to_main
          else
            render(:action => 'create_form', :layout => true)
          end
        end
        type.js do
          if successful?
            render :action => 'create', :layout => false
          else
            render :update do |page|
              page.replace_html element_messages_id(:action => :create), :partial => 'form_messages'
            end
          end
        end
        type.xml { render :xml => response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.json { render :text => response_object.to_json, :content_type => Mime::JSON, :status => response_status }
        type.yaml { render :text => response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end

    protected

    def do_new
      @record = active_scaffold_config.model.new
    end

    def do_create
      @record = active_scaffold_config.model.new(params[:record])
      build_associations(@record)
      @record.save
    end
  end
end
