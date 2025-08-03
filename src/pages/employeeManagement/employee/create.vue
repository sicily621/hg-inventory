<template>
  <div class="flex flex-col">
    <el-card class="w-full h-full">
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-position="top"
        class="flex relative flex-1"
        label-width="120px"
        require-asterisk-position="right"
      >
        <div class="width-300 d-flex">
          <el-form-item label="用户名" prop="username">
            <el-input
              v-model="form.username"
              class="flex-1"
              placeholder="请输入用户名"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="编码" prop="code">
            <el-input
              v-model="form.code"
              class="flex-1"
              placeholder="请输入编码"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input
              v-model="form.password"
              class="flex-1"
              placeholder="请输入密码"
              maxlength="32"
              :show-password="true"
              required
            >
            </el-input>
            <el-button type="primary" class="m-l-2" @click="resetPwd"
              >重置</el-button
            >
          </el-form-item>
          <el-form-item label="真实姓名" prop="realName">
            <el-input
              v-model="form.realName"
              class="flex-1"
              placeholder="请输入真实姓名"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="职位" prop="position">
            <el-input
              v-model="form.position"
              class="flex-1"
              placeholder="请输入职位"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
        </div>
        <div class="width-300 d-flex m-l-16">
          <el-form-item label="所属部门" prop="departmentId">
            <el-select v-model="form.departmentId" placeholder="请选择部门">
              <el-option
                v-for="item in departmentOptions"
                :key="item.value"
                :label="item.name"
                :value="item.value"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="角色" prop="roleId">
            <el-select v-model="form.roleId" placeholder="请选择角色">
              <el-option
                v-for="item in roleOptions"
                :key="item.value"
                :label="item.name"
                :value="item.value"
              />
            </el-select>
          </el-form-item>

          <el-form-item label="电话" prop="phone">
            <el-input
              v-model="form.phone"
              class="flex-1"
              placeholder="请输入电话"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item label="邮箱" prop="email">
            <el-input
              v-model="form.email"
              class="flex-1"
              placeholder="请输入邮箱"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
        </div>
        <div class="width-300 d-flex m-l-16">
          <el-form-item label="头像">
            <el-upload
              action=""
              :auto-upload="false"
              :show-file-list="false"
              :on-change="handleFileChange"
              accept="image/jpeg,image/png"
              class="avatar-upload flex flex-center"
            >
              <img
                v-if="imageUrl"
                :src="imageUrl"
                class="avatar"
                alt="用户头像"
              />
              <el-icon v-else><Avatar /></el-icon>
            </el-upload>
          </el-form-item>
          <el-form-item label="性别" prop="gender">
            <el-radio-group v-model="form.gender">
              <el-radio :value="1">男</el-radio>
              <el-radio :value="0">女</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="form.status">
              <el-radio :value="1">在职</el-radio>
              <el-radio :value="0">离职</el-radio>
            </el-radio-group>
          </el-form-item>
        </div>
      </el-form>
    </el-card>
  </div>
</template>
<script lang="ts" setup>
import { ref, reactive } from "vue";
import { Employee, createEmployee, editEmployee } from "../api/employee";
import type { UploadProps } from "element-plus";
import md5 from "js-md5";
const props = defineProps<{ data: Employee | null }>();
const formRef = ref();
const defaultPwd = "Admin@123456";
//表单
const form = ref<Employee>({
  code: "",
  username: "",
  password: "",
  realName: "",
  departmentId: 0,
  roleId: 0,
  gender: 1,
  avatar: "defaultAvatar.png",
  avatarFile: null,
  position: "",
  phone: "",
  email: "",
  status: 1,
});
//合并props
if (props.data) {
  Object.assign(form.value, props.data);
  form.value.password = "";
}
const validatePwd = (rule: any, value: any, callback: any) => {
  const passwordReg =
    /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,20}$/;
  if (value && !passwordReg.test(value)) {
    callback(new Error("密码必须8-20位，必须包含大小写字母、数字和特殊符号"));
  } else {
    callback();
  }
};
const validatePhone = (rule: any, value: any, callback: any) => {
  const phoneReg = /^1[3-9]\d{9}$/;
  if (value === "") {
    callback(new Error("不能为空"));
  } else if (!phoneReg.test(value)) {
    callback(new Error("请输入正确手机号"));
  } else {
    callback();
  }
};
const validateEmail = (rule: any, value: any, callback: any) => {
  const emailReg = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
  if (value === "") {
    callback(new Error("不能为空"));
  } else if (!emailReg.test(value)) {
    callback(new Error("请输入正确邮箱"));
  } else {
    callback();
  }
};
const rules = reactive({
  code: [{ required: true, message: "不能为空" }],
  username: [{ required: true, message: "不能为空" }],
  password: [{ validator: validatePwd, trigger: "blur" }],
  realName: [{ required: true, message: "不能为空" }],
  phone: [{ required: true, validator: validatePhone, trigger: "blur" }],
  email: [{ required: true, validator: validateEmail, trigger: "blur" }],
});
const departmentOptions = ref([{ name: "全部", value: 0 }]);
const roleOptions = ref([{ name: "全部", value: 0 }]);

const imageUrl = ref("");

// 处理文件选择
const handleFileChange: UploadProps["onChange"] = (file: any) => {
  // 读取文件并显示预览
  const reader = new FileReader();
  reader.onload = (e: any) => {
    imageUrl.value = e.target.result;
  };
  reader.readAsDataURL(file.raw);

  form.value.avatarFile = file.raw;
};
const resetPwd = () => {};
const confirmSave = async (cb?: Function) => {
  const valid = await formRef.value.validate();
  if (valid) {
    const params = { ...form.value };
    if (params.id) {
      if (params?.password?.length) {
        params.password = md5(params.password);
      } else {
        delete params["password"];
      }
    } else {
      params.password = md5(defaultPwd);
    }
    if (!form.value.avatarFile) delete params["avatarFile"];
    const api = params.id ? editEmployee : createEmployee;
    await api(params);
    ElMessage({
      type: "success",
      message: "保存成功",
    });
    cb && cb();
  }
};

defineExpose({ confirmSave });
</script>
<style lang="scss" scoped>
@use "@@/assets/styles/size.scss" as *;
.width-300 {
  width: zrem(300);
}
.avatar-upload {
  font-size: zrem(20);
  border: zrem(1) solid var(--el-border-color-darker);
  border-radius: 50%;
  &,
  & img {
    width: zrem(60);
    height: zrem(60);
  }
}
</style>
