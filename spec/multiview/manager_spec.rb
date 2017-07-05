RSpec.describe Multiview::Manager do
  subject { Multiview::Manager.new({'test' => 'v2'}) }
  let(:env) { Rack::MockRequest.env_for('/') }
  let(:req) { ActionDispatch::Request.new(env) }
  let(:v1_cls) do
    Class.new(ActionController::Base) do
      class << self
        attr_accessor :counter

        def counter
          @counter ||= 0
        end
      end

      def index
        self.class.counter += 1
        render plain: 'hello'
      end

      def my_action
        self.class.counter += 1
        render plain: 'hello my_action'
      end
    end
  end
  let(:v2_cls) { Class.new(TestController) }
  let(:other_cls) { Class.new(ActionController::Base) }
  let(:ctrls) { [v1_cls, v2_cls, other_cls] }

  before :each do
    stub_const('TestController', v1_cls)
    stub_const('V2::TestController', v2_cls)
    stub_const('Other::TestController', other_cls)

    v2_cls.class_eval do
      def index
        self.class.counter += 1
        response.headers['X-Test'] = 'xyz'
        render plain: 'hello v2', status: 201
      end
    end

    other_cls.class_eval do
      class << self
        attr_accessor :counter

        def counter
          @counter ||= 0
        end
      end

      def index
        self.class.counter += 1
        response.headers['X-Test'] = 'other'
        render plain: 'hello other', status: 400
      end
    end
  end

  describe '#dispatch' do
    it 'should dispatch if path match current request' do
      status, headers, rack_body = subject.dispatch(env, 'test', 'index')
      expect(status).to eql(201)
      expect(rack_body.body).to eql('hello v2')
      expect(headers['X-Test']).to eql('xyz')

      # don't call v1 action
      expect(ctrls.sum(&:counter)).to eql(1)
      expect(v2_cls.counter).to eql(1)

      expect(env['multiview'][:version]).to eql('v2')
    end

    it 'should call specify version controller if give version' do
      status, headers, rack_body = subject.dispatch(env, 'test', 'index', 'other')
      expect(status).to eql(400)
      expect(rack_body.body).to eql('hello other')
      expect(headers['X-Test']).to eql('other')

      expect(ctrls.sum(&:counter)).to eql(1)
      expect(other_cls.counter).to eql(1)

      expect(env['multiview'][:version]).to eql('other')
    end
  end

  describe '#redispatch' do
    let(:root_path) { Pathname.new('/path/to/project') }
    let(:ctrl_obj) do
      v1_cls.new.tap do |c|
        c.request = req
        c.response = ActionDispatch::Response.new 200, {}
      end
    end

    it 'should dispatch if path match current request' do
      subject.redispatch(ctrl_obj, 'test', 'index')

      expect(ctrl_obj.status).to eql(201)
      expect(ctrl_obj.response_body.body).to eql('hello v2')
      expect(ctrl_obj.headers['X-Test']).to eql('xyz')

      expect(ctrls.sum(&:counter)).to eql(1)
      expect(v2_cls.counter).to eql(1)

      expect(env['multiview'][:version]).to eql('v2')
    end

    it 'should call specify version controller if give version' do
      subject.redispatch(ctrl_obj, 'test', 'index', 'other')
      expect(ctrl_obj.status).to eql(400)
      expect(ctrl_obj.response_body.body).to eql('hello other')
      expect(ctrl_obj.headers['X-Test']).to eql('other')

      expect(ctrls.sum(&:counter)).to eql(1)
      expect(other_cls.counter).to eql(1)

      expect(env['multiview'][:version]).to eql('other')
    end

    it 'should prepend view path if not found action' do
      allow(Rails).to receive(:root).and_return(root_path)
      expect(ctrl_obj).to receive(:prepend_view_path).with(root_path.join('app/views/asdf'))

      subject.redispatch(ctrl_obj, 'test', 'my_action', 'asdf')
      expect(env['multiview'][:version]).to eql('asdf')
    end
  end
end

