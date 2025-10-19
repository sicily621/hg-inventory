<template>
  <div class="login-container">
    <ThemeSwitch v-if="settingsStore.showThemeSwitch" class="theme-switch" />
    <!-- <Owl :close-eyes="isFocus" /> -->
    <div class="login-card">
      <div class="title flex flex-center">
        <img src="@@/assets/images/layouts/logo.png" />
        <span>慧谷商贸进销存系统</span>
      </div>
      <div class="content">
        <el-form
          ref="loginFormRef"
          :model="loginFormData"
          :rules="loginFormRules"
          @keyup.enter="handleLogin"
        >
          <el-form-item prop="username">
            <el-input
              v-model.trim="loginFormData.username"
              placeholder="用户名"
              type="text"
              tabindex="1"
              :prefix-icon="User"
              size="large"
            />
          </el-form-item>
          <el-form-item prop="password">
            <el-input
              v-model.trim="loginFormData.password"
              placeholder="密码"
              type="password"
              tabindex="2"
              :prefix-icon="Lock"
              size="large"
              show-password
              @blur="handleBlur"
              @focus="handleFocus"
            />
          </el-form-item>
          <el-form-item prop="code">
            <el-input
              v-model.trim="loginFormData.code"
              placeholder="验证码"
              type="text"
              tabindex="3"
              :prefix-icon="Key"
              maxlength="7"
              size="large"
              @blur="handleBlur"
              @focus="handleFocus"
            >
              <template #append>
                <canvas
                  ref="captchaCanvas"
                  @click="refreshCaptcha"
                  class="captcha-canvas"
                  width="100"
                  height="30"
                  title="点击刷新"
                ></canvas>
              </template>
            </el-input>
          </el-form-item>
          <el-button
            :loading="loading"
            type="primary"
            size="large"
            @click.prevent="handleLogin"
          >
            登 录
          </el-button>
        </el-form>
      </div>
    </div>
  </div>
</template>
<script lang="ts" setup>
import type { FormRules } from "element-plus";
import type { LoginRequestData } from "./apis/type";
import ThemeSwitch from "@@/components/ThemeSwitch/index.vue";
import { Key, Lock, User } from "@element-plus/icons-vue";
import { useSettingsStore } from "@/pinia/stores/settings";
import { useUserStore } from "@/pinia/stores/user";
import { usePermissionStore } from "@/pinia/stores/permission";
import { getRolePermissionRelationsByRoleId } from "@/pages/employeeManagement/api/rolePermissionRelations";
import { getPermissionListByIds } from "@/pages/employeeManagement/api/permission";
import { loginApi } from "./apis";
import { useFocus } from "./composables/useFocus";
import md5 from "js-md5";
import { onMounted } from "vue";

const router = useRouter();

const userStore = useUserStore();

const settingsStore = useSettingsStore();

const permissionStore = usePermissionStore();

const { handleBlur, handleFocus } = useFocus();

/** 登录表单元素的引用 */
const loginFormRef = ref();

/** 登录按钮 Loading */
const loading = ref(false);

/** 登录表单数据 */
const loginFormData: LoginRequestData = reactive({
  username: "admin",
  password: "Admin@123456",
  code: "",
});
const validateCode = (rule: any, value: any, callback: any) => {
  if (!value || !rule) {
    return callback(new Error("验证码不能为空"));
  } else {
    // 不区分大小写验证
    const isMatch =
      loginFormData.code.toLowerCase() === currentCode.toLowerCase();

    if (isMatch) {
      callback();
    } else {
      callback(new Error("验证码错误"));
    }
  }
};
/** 登录表单校验规则 */
const loginFormRules: FormRules = {
  username: [{ required: true, message: "请输入用户名", trigger: "blur" }],
  password: [
    { required: true, message: "请输入密码", trigger: "blur" },
    { min: 8, max: 16, message: "长度在 8 到 16 个字符", trigger: "blur" },
  ],
  code: [{ validator: validateCode, trigger: "blur" }],
};

/** 登录 */
function handleLogin() {
  loginFormRef.value?.validate((valid: boolean) => {
    if (!valid) {
      ElMessage.error("表单校验不通过");
      return;
    }
    loading.value = true;
    const params = { ...loginFormData };
    params.password = md5(params.password);
    loginApi(params)
      .then(({ data }) => {
        const {
          id,
          token,
          departmentId,
          roleId,
          username,
          tokenTimeout,
          avatar,
        } = data;
        userStore.setToken(token, tokenTimeout);
        userStore.setInfo({
          id,
          departmentId,
          roleId,
          username,
          tokenTimeout,
          avatar,
        });
        if (roleId) {
          getRolePermissionRelationsByRoleId(roleId).then((res) => {
            const permissions = (res as any).data.map(
              (item: any) => item.permissionId,
            );
            if (permissions.length) {
              getPermissionListByIds(permissions).then((res: any) => {
                permissionStore.setPermissions(res.data, tokenTimeout);
                router.push("/");
              });
            } else {
              router.push("/");
            }
          });
        } else {
          router.push("/");
        }
      })
      .catch(() => {
        loginFormData.password = "";
      })
      .finally(() => {
        loading.value = false;
      });
  });
}

// 画布引用
const captchaCanvas = ref(null);
// 当前验证码
let currentCode = "";

// 自定义字符集（中英文数字混合）
const charPool = [
  // 数字
  "0",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  // 大写字母
  "A",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "P",
  "Q",
  "R",
  "S",
  "T",
  "U",
  "V",
  "W",
  "X",
  "Y",
  "Z",
  // 小写字母
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k",
  "l",
  "m",
  "n",
  "o",
  "p",
  "q",
  "r",
  "s",
  "t",
  "u",
  "v",
  "w",
  "x",
  "y",
  "z",
];

// 生成随机验证码
const generateCode = (length = 4) => {
  let code = "";
  for (let i = 0; i < length; i++) {
    const randomIndex = Math.floor(Math.random() * charPool.length);
    code += charPool[randomIndex];
  }
  currentCode = code;
  return code;
};

// 绘制验证码
const drawCaptcha = () => {
  if (!captchaCanvas.value) return;

  const canvas = captchaCanvas.value;
  const ctx = (canvas as any).getContext("2d");
  const width = (canvas as any).width;
  const height = (canvas as any).height;

  // 清空画布
  ctx.clearRect(0, 0, width, height);

  // 绘制背景
  ctx.fillStyle = "#f3f3f3";
  ctx.fillRect(0, 0, width, height);

  // 生成验证码
  const code = generateCode(4);

  // 设置字体
  ctx.font = 'bold 20px "Microsoft YaHei", Arial, sans-serif';

  // 绘制每个字符
  for (let i = 0; i < code.length; i++) {
    // 随机颜色
    ctx.fillStyle = `rgb(${Math.random() * 80 + 50}, ${Math.random() * 80 + 50}, ${Math.random() * 80 + 50})`;

    // 计算位置
    const x = 12 + i * 20;
    const y = height / 2 + 8;

    // 保存当前状态
    ctx.save();

    // 平移并旋转
    ctx.translate(x, y);
    // ctx.rotate(rotate);

    // 绘制字符
    ctx.fillText(code[i], 0, 0);

    // 恢复状态
    ctx.restore();
  }
};

// 刷新验证码
const refreshCaptcha = () => {
  drawCaptcha();
};

// 组件挂载时绘制验证码
onMounted(() => {
  drawCaptcha();
});
</script>

<style lang="scss" scoped>
@use "@@/assets/styles/size.scss" as *;
.login-container {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  width: 100%;
  min-height: 100%;
  .theme-switch {
    position: fixed;
    top: 5%;
    right: 5%;
    cursor: pointer;
  }
  .login-card {
    width: 480px;
    max-width: 90%;
    border-radius: 20px;
    box-shadow: 0 0 10px #dcdfe6;
    background-color: var(--el-bg-color);
    overflow: hidden;
    .title {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 150px;
      font-size: zrem(24);
      img {
        height: zrem(36);
      }
      span {
        margin-left: zrem(10);
        background-clip: text;
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-image: linear-gradient(
          to bottom,
          var(--el-color-primary-dark-2),
          var(--el-color-primary)
        );
        font-weight: 600;
      }
    }
    .content {
      padding: 20px 50px 50px 50px;
      :deep(.el-input-group__append) {
        padding: 0;
        overflow: hidden;
        .el-image {
          width: 100px;
          height: 40px;
          border-left: 0px;
          user-select: none;
          cursor: pointer;
          text-align: center;
        }
      }
      .el-button {
        width: 100%;
        margin-top: 10px;
      }
    }
  }
}
</style>
