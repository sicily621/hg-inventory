declare module "js-md5" {
  function md5(str: string): string;
  export default md5;
}
declare module "*.vue" {
  import type { DefineComponent } from "vue";
  const component: DefineComponent<{}, {}, any>;
  export default component;
}
