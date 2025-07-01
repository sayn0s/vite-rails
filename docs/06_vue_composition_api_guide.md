# Vue2.7 Composition API 移行ガイド

Vue2.7でOptions APIからComposition APIへの移行方法を初心者にもわかりやすく解説します。

## 📚 目次

1. [Composition APIとは？](#composition-apiとは)
2. [Options API vs Composition API](#options-api-vs-composition-api)
3. [基本的な変換方法](#基本的な変換方法)
4. [実践例：TODOアプリの変換](#実践例todoアプリの変換)
5. [`<script setup>`構文](#script-setup構文)
6. [注意点とベストプラクティス](#注意点とベストプラクティス)
7. [Vue3移行への準備](#vue3移行への準備)

## 🎯 Composition APIとは？

Composition APIは**Vue.jsの新しい記述方法**で、コンポーネントのロジックをより柔軟に組織化できます。

### **従来の問題（Options API）**
```javascript
// 機能が散らばってしまう
export default {
  data() { /* データ */ },
  computed: { /* 計算プロパティ */ },
  methods: { /* メソッド */ },
  mounted() { /* ライフサイクル */ }
}
```

### **Composition APIの解決**
```javascript
// 関連する機能をまとめて記述
export default {
  setup() {
    // TODOに関する全ての機能をここに集約
    const todos = ref([])
    const addTodo = () => { /* ... */ }
    const fetchTodos = () => { /* ... */ }
    
    return { todos, addTodo, fetchTodos }
  }
}
```

## ⚖️ Options API vs Composition API

### **Options API（従来）**
```vue
<script>
export default {
  data() {
    return {
      count: 0,
      message: 'Hello'
    }
  },
  computed: {
    doubleCount() {
      return this.count * 2
    }
  },
  methods: {
    increment() {
      this.count++
    }
  },
  mounted() {
    console.log('mounted!')
  }
}
</script>
```

### **Composition API（新しい）**
```vue
<script>
import { ref, computed, onMounted } from 'vue'

export default {
  setup() {
    // リアクティブなデータ
    const count = ref(0)
    const message = ref('Hello')
    
    // 計算プロパティ
    const doubleCount = computed(() => count.value * 2)
    
    // メソッド
    const increment = () => {
      count.value++
    }
    
    // ライフサイクル
    onMounted(() => {
      console.log('mounted!')
    })
    
    // テンプレートで使用するものをreturn
    return {
      count,
      message,
      doubleCount,
      increment
    }
  }
}
</script>
```

## 🔄 基本的な変換方法

### **1. データの変換**

**Options API:**
```javascript
data() {
  return {
    todos: [],
    loading: false
  }
}
```

**Composition API:**
```javascript
import { ref } from 'vue'

const todos = ref([])
const loading = ref(false)
```

### **2. 計算プロパティの変換**

**Options API:**
```javascript
computed: {
  completedCount() {
    return this.todos.filter(todo => todo.completed).length
  }
}
```

**Composition API:**
```javascript
import { computed } from 'vue'

const completedCount = computed(() => 
  todos.value.filter(todo => todo.completed).length
)
```

### **3. メソッドの変換**

**Options API:**
```javascript
methods: {
  addTodo() {
    this.todos.push({ title: 'New Todo' })
  }
}
```

**Composition API:**
```javascript
const addTodo = () => {
  todos.value.push({ title: 'New Todo' })
}
```

### **4. ライフサイクルの変換**

**Options API:**
```javascript
async mounted() {
  await this.fetchTodos()
}
```

**Composition API:**
```javascript
import { onMounted } from 'vue'

onMounted(async () => {
  await fetchTodos()
})
```

## 🚀 実践例：TODOアプリの変換

現在のOptions APIからComposition APIに変換してみましょう。

### **変換前（Options API）**
```vue
<script>
export default {
  name: "App",
  data() {
    return {
      todos: [],
      newTodo: { title: "", completed: false },
      loading: false,
    };
  },
  computed: {
    completedCount() {
      return this.todos.filter((todo) => todo.completed).length;
    },
  },
  async mounted() {
    await this.fetchTodos();
  },
  methods: {
    async fetchTodos() {
      this.loading = true;
      // ... API呼び出し
      this.loading = false;
    }
  }
}
</script>
```

### **変換後（Composition API）**
```vue
<script>
import { ref, reactive, computed, onMounted } from 'vue'

export default {
  name: "App",
  setup() {
    // 🔥 リアクティブなデータ
    const todos = ref([])
    const newTodo = reactive({
      title: "",
      completed: false,
    })
    const loading = ref(false)

    // 🧮 計算プロパティ
    const completedCount = computed(() => 
      todos.value.filter(todo => todo.completed).length
    )

    // ⚡ メソッド
    const apiUrl = (path = "") => `/api/v1/todos${path}`
    
    const fetchTodos = async () => {
      try {
        loading.value = true
        const response = await fetch(apiUrl())
        if (!response.ok) throw new Error("取得に失敗しました")
        todos.value = await response.json()
      } catch (error) {
        console.error("TODO取得エラー:", error)
        alert("TODOの取得に失敗しました")
      } finally {
        loading.value = false
      }
    }

    // 🔄 ライフサイクル
    onMounted(async () => {
      await fetchTodos()
    })

    // 📤 テンプレートに公開
    return {
      todos,
      newTodo,
      loading,
      completedCount,
      fetchTodos
    }
  }
}
</script>
```

## ✨ `<script setup>`構文

Vue2.7では`<script setup>`も使用できます（実験的機能）。

### **通常のComposition API**
```vue
<script>
import { ref, computed } from 'vue'

export default {
  setup() {
    const count = ref(0)
    const doubleCount = computed(() => count.value * 2)
    
    return { count, doubleCount }
  }
}
</script>
```

### **`<script setup>`版**
```vue
<script setup>
import { ref, computed } from 'vue'

const count = ref(0)
const doubleCount = computed(() => count.value * 2)
// 自動的にreturnされる！
</script>
```

### **TODOアプリを`<script setup>`で書く場合**

```vue
<script setup>
import { ref, reactive, computed, onMounted } from 'vue'

// リアクティブなデータ
const todos = ref([])
const newTodo = reactive({
  title: "",
  completed: false,
})
const loading = ref(false)

// 計算プロパティ
const completedCount = computed(() => 
  todos.value.filter(todo => todo.completed).length
)
const pendingCount = computed(() => 
  todos.value.filter(todo => !todo.completed).length
)

// ヘルパー関数
const apiUrl = (path = "") => `/api/v1/todos${path}`

// メソッド
const fetchTodos = async () => {
  try {
    loading.value = true
    const response = await fetch(apiUrl())
    if (!response.ok) throw new Error("取得に失敗しました")
    todos.value = await response.json()
  } catch (error) {
    console.error("TODO取得エラー:", error)
    alert("TODOの取得に失敗しました")
  } finally {
    loading.value = false
  }
}

const createTodo = async () => {
  if (!newTodo.title.trim()) return

  try {
    const response = await fetch(apiUrl(), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ todo: newTodo }),
    })

    if (!response.ok) throw new Error("作成に失敗しました")

    const createdTodo = await response.json()
    todos.value.push(createdTodo)
    newTodo.title = ""
  } catch (error) {
    console.error("TODO作成エラー:", error)
    alert("TODOの作成に失敗しました")
  }
}

const toggleTodo = async (todo) => {
  try {
    const updatedTodo = { ...todo, completed: !todo.completed }
    const response = await fetch(apiUrl(`/${todo.id}`), {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ todo: updatedTodo }),
    })

    if (!response.ok) throw new Error("更新に失敗しました")

    const result = await response.json()
    const index = todos.value.findIndex((t) => t.id === todo.id)
    if (index !== -1) {
      todos.value[index] = result
    }
  } catch (error) {
    console.error("TODO更新エラー:", error)
    alert("TODOの更新に失敗しました")
  }
}

const deleteTodo = async (id) => {
  if (!confirm("このTODOを削除しますか？")) return

  try {
    const response = await fetch(apiUrl(`/${id}`), {
      method: "DELETE",
    })

    if (!response.ok) throw new Error("削除に失敗しました")

    todos.value = todos.value.filter((todo) => todo.id !== id)
  } catch (error) {
    console.error("TODO削除エラー:", error)
    alert("TODOの削除に失敗しました")
  }
}

// ライフサイクル
onMounted(async () => {
  await fetchTodos()
})
</script>
```

## ⚠️ 注意点とベストプラクティス

### **1. `ref`と`reactive`の使い分け**

```javascript
// ✅ プリミティブ値にはref
const count = ref(0)
const message = ref('Hello')

// ✅ オブジェクトにはreactiveかref
const user = reactive({ name: 'Alice', age: 25 })
// または
const user = ref({ name: 'Alice', age: 25 })

// ❌ プリミティブ値にreactiveは不可
const count = reactive(0) // エラー！
```

### **2. `ref`の`.value`を忘れずに**

```javascript
const count = ref(0)

// ✅ JavaScript内では.valueが必要
count.value++
console.log(count.value)

// ✅ テンプレート内では.valueは不要
// <template>{{ count }}</template>
```

### **3. `reactive`のデストラクチャリング注意**

```javascript
const user = reactive({ name: 'Alice', age: 25 })

// ❌ リアクティビティが失われる
const { name, age } = user

// ✅ toRefsを使用
import { toRefs } from 'vue'
const { name, age } = toRefs(user)
```

### **4. ライフサイクルフックの対応表**

| Options API | Composition API |
|-------------|-----------------|
| `beforeCreate` | `setup()` |
| `created` | `setup()` |
| `beforeMount` | `onBeforeMount` |
| `mounted` | `onMounted` |
| `beforeUpdate` | `onBeforeUpdate` |
| `updated` | `onUpdated` |
| `beforeUnmount` | `onBeforeUnmount` |
| `unmounted` | `onUnmounted` |

### **5. Vue2.7での制限事項**

```javascript
// ❌ Vue2.7では使用不可
import { defineComponent } from 'vue' // Vue3のみ

// ✅ Vue2.7で使用可能
import { ref, reactive, computed, onMounted, watch } from 'vue'
```

## 🚀 Vue3移行への準備

Composition APIを使用することで、Vue3への移行が非常に簡単になります。

### **現在（Vue2.7）**
```javascript
import { ref, computed, onMounted } from 'vue'
```

### **Vue3移行時（ほぼ同じ）**
```javascript
import { ref, computed, onMounted } from 'vue'
// 基本的にコードはそのまま使える！
```

### **主な変更点（Vue3移行時）**
1. `@vitejs/plugin-vue2` → `@vitejs/plugin-vue`
2. `vue@2.7.16` → `vue@3.x.x`
3. 一部のライフサイクル名変更（`destroyed` → `unmounted`）

## 🎉 まとめ

### **Composition APIのメリット**
- ✅ **再利用性**: ロジックを関数として切り出し可能
- ✅ **型安全性**: TypeScriptとの相性が良い
- ✅ **可読性**: 関連する機能をまとめて記述
- ✅ **Vue3準備**: 移行がスムーズ

### **移行のコツ**
1. **段階的移行**: 一度にすべてを変更しない
2. **小さなコンポーネントから**: 複雑なものは後回し
3. **テストを充実**: 動作確認を入念に
4. **チーム学習**: 全員で理解を深める

これでVue2.7 Composition APIの基本は完璧です！🎯