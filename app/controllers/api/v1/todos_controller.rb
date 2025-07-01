class Api::V1::TodosController < ApiController
  before_action :find_todo, only: [:show, :update, :destroy]

  def index
    todos = Todo.all
    render json: todos.map(&:to_hash)
  end

  def show
    render json: @todo.to_hash
  end

  def create
    Rails.logger.info "Creating todo with params: #{todo_params.inspect}"
    
    begin
      todo = Todo.create(todo_params)
      Rails.logger.info "Todo created: #{todo.inspect}"
      
      # 成功判定を変更：idが存在し、エラーがない場合は成功
      if todo.id.present? && (!todo.respond_to?(:errors) || todo.errors.empty?)
        Rails.logger.info "Todo creation successful"
        render json: todo.to_hash, status: :created
      else
        Rails.logger.error "Todo creation failed: #{todo.errors&.full_messages}"
        render json: { 
          error: "Failed to create todo",
          details: todo.errors&.full_messages || ["Unknown error"]
        }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Exception in todo creation: #{e.message}"
      render json: { 
        error: "Server error", 
        message: e.message 
      }, status: :internal_server_error
    end
  end

  def update
    if @todo.update(todo_params)
      render json: @todo.to_hash
    else
      render json: { 
        error: "Failed to update todo",
        details: @todo.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def destroy
    if @todo.destroy
      head :no_content
    else
      render json: { error: "Failed to delete todo" }, status: :unprocessable_entity
    end
  end

  private

  def find_todo
    @todo = Todo.find(params[:id])
    unless @todo
      render json: { error: 'Todo not found' }, status: :not_found
    end
  end

  def todo_params
    params.require(:todo).permit(:title, :completed)
  end
end
