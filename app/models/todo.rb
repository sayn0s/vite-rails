class Todo
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Serialization
  include ActiveModel::Validations

  attribute :id, :integer
  attribute :title, :string
  attribute :completed, :boolean, default: false
  attribute :created_at, :string

  validates :title, presence: true, length: { minimum: 1 }

  # JSONファイルでのデータ保存
  DATA_FILE = Rails.root.join('data', 'todos.json')

  def self.all
    load_data.map { |data| new(data) }
  end

  def self.find(id)
    all.find { |todo| todo.id == id.to_i }
  end

  def self.create(attributes)
    Rails.logger.info "Todo.create called with: #{attributes.inspect}"
    
    todo = new(attributes.merge(
      id: next_id, 
      created_at: Time.current.iso8601
    ))
    
    Rails.logger.info "Todo instance created: #{todo.inspect}"
    Rails.logger.info "Todo valid?: #{todo.valid?}"
    
    if todo.valid?
      begin
        todos = all
        todos << todo
        save_data(todos.map(&:to_hash))
        Rails.logger.info "Todo saved successfully"
        # 保存後にpersistedフラグをセット
        todo.instance_variable_set(:@persisted, true)
        todo
      rescue => e
        Rails.logger.error "Error saving todo: #{e.message}"
        todo.errors.add(:base, "Failed to save: #{e.message}")
        todo
      end
    else
      Rails.logger.error "Todo validation failed: #{todo.errors.full_messages}"
      todo
    end
  end

  def persisted?
    # 明示的にpersistedフラグをチェック、またはidの存在をチェック
    @persisted == true || (id.present? && errors.empty?)
  end

  def to_hash
    {
      id: id,
      title: title,
      completed: completed,
      created_at: created_at
    }
  end

  def update(attributes)
    assign_attributes(attributes)
    save
  end

  def save
    todos = self.class.all
    index = todos.find_index { |t| t.id == id }
    todos[index] = self if index
    self.class.save_data(todos.map(&:to_hash))
    self
  end

  def destroy
    todos = self.class.all.reject { |t| t.id == id }
    self.class.save_data(todos.map(&:to_hash))
    true
  end

  private

  def self.load_data
    return [] unless File.exist?(DATA_FILE)
    
    begin
      content = File.read(DATA_FILE, encoding: 'UTF-8')
      JSON.parse(content)
    rescue JSON::ParserError, Errno::ENOENT => e
      Rails.logger.error "Error loading data: #{e.message}"
      []
    end
  end

  def self.save_data(todos_array)
    begin
      FileUtils.mkdir_p(File.dirname(DATA_FILE))
      File.write(DATA_FILE, JSON.pretty_generate(todos_array), encoding: 'UTF-8')
      Rails.logger.info "Data saved successfully"
    rescue => e
      Rails.logger.error "Error saving data: #{e.message}"
      raise e
    end
  end

  def self.next_id
    existing_ids = load_data.map { |t| t['id'] }.compact
    existing_ids.empty? ? 1 : existing_ids.max + 1
  end
end 