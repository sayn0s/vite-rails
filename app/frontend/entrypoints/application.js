console.log("Vite ⚡️ Rails");

// Vue 3 with @vue/compat initialization
import { createApp, configureCompat } from "vue";
import App from "../App.vue";

// グローバル互換設定
configureCompat({
  MODE: 2, // Vue 2 互換モード
  GLOBAL_MOUNT: false,
  GLOBAL_EXTEND: false,
  GLOBAL_PROTOTYPE: false,
  GLOBAL_SET: false,
  GLOBAL_DELETE: false,
  GLOBAL_OBSERVABLE: false,
  CONFIG_SILENT: false,
  CONFIG_DEVTOOLS: false,
  CONFIG_KEY_CODES: false,
  CONFIG_PRODUCTION_TIP: false,
  CONFIG_IGNORED_ELEMENTS: false,
  CONFIG_WHITESPACE: false,
  CONFIG_OPTION_MERGE_STRATS: false,
  INSTANCE_SET: false,
  INSTANCE_DELETE: false,
  INSTANCE_DESTROY: false,
  INSTANCE_EVENT_EMITTER: false,
  INSTANCE_EVENT_HOOKS: false,
  INSTANCE_CHILDREN: false,
  INSTANCE_LISTENERS: false,
  INSTANCE_SCOPED_SLOTS: false,
  PROPS_DEFAULT_THIS: false,
  INSTANCE_ATTRS_CLASS_STYLE: false,
  OPTIONS_DATA_FN: false,
  OPTIONS_DATA_MERGE: false,
  OPTIONS_BEFORE_DESTROY: false,
  OPTIONS_DESTROYED: false,
  WATCH_ARRAY: false,
  V_ON_KEYCODE_MODIFIER: false,
  CUSTOM_DIR: false,
  ATTR_FALSE_VALUE: false,
  ATTR_ENUMERATED_COERCION: false,
  TRANSITION_CLASSES: false,
  COMPONENT_ASYNC: false,
  COMPONENT_FUNCTIONAL: false,
  COMPONENT_V_MODEL: false,
  RENDER_FUNCTION: false,
  FILTERS: false,
  PRIVATE_APIS: false,
});

const app = createApp(App);
app.mount("#vue-app");
