class Api::V1::TodosController < ApplicationController
  DATA_PATH = Rails.root.join('data', 'todos.json')

  def index
    render json: todos
  end

  def show
    todo = todos.find { |t| t['id'] == params[:id].to_i }
    if todo
      render json: todo
    else
      head :not_found
    end
  end

  def create
    new_todo = todo_params.merge('id' => next_id, 'created_at' => Time.now.utc.iso8601)
    all = todos << new_todo
    save_todos(all)
    render json: new_todo, status: :created
  end

  def update
    all = todos
    todo = all.find { |t| t['id'] == params[:id].to_i }
    if todo
      todo.merge!(todo_params)
      save_todos(all)
      render json: todo
    else
      head :not_found
    end
  end

  def destroy
    all = todos
    todo = all.find { |t| t['id'] == params[:id].to_i }
    if todo
      all.delete(todo)
      save_todos(all)
      head :no_content
    else
      head :not_found
    end
  end

  private

  def todos
    File.exist?(DATA_PATH) ? JSON.parse(File.read(DATA_PATH)) : []
  end

  def save_todos(arr)
    FileUtils.mkdir_p(DATA_PATH.dirname)
    File.write(DATA_PATH, JSON.pretty_generate(arr))
  end

  def next_id
    todos.map { |t| t['id'] }.max.to_i + 1
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :completed, :priority)
  end
end 