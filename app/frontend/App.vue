<template>
  <div id="app">
    <h1>TODOアプリ</h1>

    <!-- TODO作成フォーム -->
    <div class="todo-form">
      <input
        v-model="newTodo.title"
        placeholder="新しいTODOを入力してください"
        @keyup.enter="createTodo"
      />
      <button @click="createTodo" :disabled="!newTodo.title">追加</button>
    </div>

    <!-- TODO一覧 -->
    <div class="todo-list">
      <div v-if="loading" class="loading">読み込み中...</div>
      <div v-else-if="todos.length === 0" class="empty">TODOがありません</div>
      <div v-else>
        <div
          v-for="todo in todos"
          :key="todo.id"
          class="todo-item"
          :class="{ completed: todo.completed }"
        >
          <input
            type="checkbox"
            :checked="todo.completed"
            @change="toggleTodo(todo)"
          />
          <span class="todo-title">{{ todo.title }}</span>
          <button @click="deleteTodo(todo.id)" class="delete-btn">削除</button>
        </div>
      </div>
    </div>

    <!-- ステータス表示 -->
    <div class="status">
      <p>
        総数: {{ todos.length }} | 完了: {{ completedCount }} | 未完了:
        {{ pendingCount }}
      </p>
    </div>
  </div>
</template>

<script>
export default {
  name: "App",
  data() {
    return {
      todos: [],
      newTodo: {
        title: "",
        completed: false,
      },
      loading: false,
    };
  },
  computed: {
    completedCount() {
      return this.todos.filter((todo) => todo.completed).length;
    },
    pendingCount() {
      return this.todos.filter((todo) => !todo.completed).length;
    },
  },
  async mounted() {
    await this.fetchTodos();
  },
  methods: {
    // API基本URL
    apiUrl(path = "") {
      return `/api/v1/todos${path}`;
    },

    // TODO一覧取得
    async fetchTodos() {
      try {
        this.loading = true;
        const response = await fetch(this.apiUrl());
        if (!response.ok) throw new Error("取得に失敗しました");
        this.todos = await response.json();
      } catch (error) {
        console.error("TODO取得エラー:", error);
        alert("TODOの取得に失敗しました");
      } finally {
        this.loading = false;
      }
    },

    // TODO作成
    async createTodo() {
      if (!this.newTodo.title.trim()) return;

      try {
        const response = await fetch(this.apiUrl(), {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ todo: this.newTodo }),
        });

        if (!response.ok) throw new Error("作成に失敗しました");

        const createdTodo = await response.json();
        this.todos.push(createdTodo);
        this.newTodo.title = ""; // フォームをクリア
      } catch (error) {
        console.error("TODO作成エラー:", error);
        alert("TODOの作成に失敗しました");
      }
    },

    // TODO完了状態切り替え
    async toggleTodo(todo) {
      try {
        const updatedTodo = { ...todo, completed: !todo.completed };
        const response = await fetch(this.apiUrl(`/${todo.id}`), {
          method: "PUT",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ todo: updatedTodo }),
        });

        if (!response.ok) throw new Error("更新に失敗しました");

        const result = await response.json();
        const index = this.todos.findIndex((t) => t.id === todo.id);
        if (index !== -1) {
          this.todos[index] = result;
        }
      } catch (error) {
        console.error("TODO更新エラー:", error);
        alert("TODOの更新に失敗しました");
      }
    },

    // TODO削除
    async deleteTodo(id) {
      if (!confirm("このTODOを削除しますか？")) return;

      try {
        const response = await fetch(this.apiUrl(`/${id}`), {
          method: "DELETE",
        });

        if (!response.ok) throw new Error("削除に失敗しました");

        this.todos = this.todos.filter((todo) => todo.id !== id);
      } catch (error) {
        console.error("TODO削除エラー:", error);
        alert("TODOの削除に失敗しました");
      }
    },
  },
};
</script>

<style>
#app {
  font-family: "Hiragino Kaku Gothic ProN", "Hiragino Sans", Meiryo, sans-serif;
  padding: 2rem;
  max-width: 600px;
  margin: 0 auto;
}

.todo-form {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.todo-form input {
  flex: 1;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-family: inherit;
}

.todo-form button {
  padding: 10px 20px;
  background: #007cba;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-family: inherit;
}

.todo-form button:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.todo-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  border: 1px solid #eee;
  border-radius: 4px;
  margin-bottom: 5px;
}

.todo-item.completed {
  background: #f9f9f9;
}

.todo-item.completed .todo-title {
  text-decoration: line-through;
  color: #999;
}

.todo-title {
  flex: 1;
  font-family: inherit;
}

.delete-btn {
  background: #dc3545;
  color: white;
  border: none;
  padding: 5px 10px;
  border-radius: 4px;
  cursor: pointer;
  font-family: inherit;
}

.delete-btn:hover {
  background: #c82333;
}

.loading,
.empty {
  text-align: center;
  padding: 20px;
  color: #666;
  font-family: inherit;
}

.status {
  margin-top: 20px;
  padding: 10px;
  background: #f5f5f5;
  border-radius: 4px;
  text-align: center;
  font-family: inherit;
}
</style>
