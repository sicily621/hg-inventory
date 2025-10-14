<template>
  <div class="flex flex-col">
    <el-card class="w-full h-full">
      <div class="zc-header-title">
        <div class="zc-header-icon"></div>
        <div class="zc-header-word">员工信息</div>
      </div>
      <el-divider />
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
          <el-form-item label="部门" prop="departmentId">
            <el-tree-select
              v-model="form.departmentId"
              placeholder="请选择部门"
              :data="departmentOptions"
              check-strictly
              :render-after-expand="false"
              :props="selectProps"
            />
          </el-form-item>
          <el-form-item label="角色" prop="roleId">
            <el-select v-model="form.roleId" placeholder="请选择角色">
              <el-option
                v-for="item in roleOptions"
                :key="item.id"
                :label="item.name"
                :value="item.id"
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
import { ref, reactive, onMounted } from "vue";
import {
  Employee,
  createEmployee,
  editEmployee,
  uploadFile,
} from "../api/employee";
import { Department, getDepartmentList } from "../api/department";
import { getRoleList } from "../api/role";
import type { UploadProps } from "element-plus";
import md5 from "js-md5";
import { ElMessage } from "element-plus";
import { formatTimeToString } from "@@/utils/datetime";
import { ModuleCode } from "@/router/moduleCode";
const props = defineProps<{ data: Employee | null }>();
const formRef = ref();
const defaultPwd = "Admin@123456";
const selectProps = { value: "id", label: "name" };
//表单
const form = ref<Employee>({
  code: `${ModuleCode.Employee}${formatTimeToString()}`,
  username: "",
  password: "",
  realName: "",
  departmentId: "",
  roleId: "",
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
  roleId: [{ required: true, message: "不能为空" }],
  departmentId: [{ required: true, message: "不能为空" }],
  password: [{ validator: validatePwd, trigger: "blur" }],
  realName: [{ required: true, message: "不能为空" }],
  phone: [{ required: true, validator: validatePhone, trigger: "blur" }],
  email: [{ required: true, validator: validateEmail, trigger: "blur" }],
});

function buildDepartmentTree(departments: Department[]) {
  const map = new Map();

  // 第一步：创建所有部门的映射并初始化children
  departments.forEach((dept: Department) => {
    map.set(dept.id, {
      ...dept,
      children: [],
    });
  });

  // 第二步：建立所有层级的父子关系
  departments.forEach((dept: Department) => {
    const current = map.get(dept.id);
    if (dept.parentId !== 0) {
      const parent = map.get(dept.parentId);
      if (parent) {
        parent.children.push(current);
      }
    }
  });

  // 第三步：收集顶级部门
  return departments
    .filter((dept: Department) => dept.parentId === 0)
    .map((dept: Department) => map.get(dept.id));
}
const departmentOptions = ref<any[]>([{ name: "无", id: 0 }]);
const roleOptions = ref<any[]>([{ name: "无", value: 0 }]);
const imageUrl = ref("");
if (form.value.avatar != "defaultAvatar.png")
  imageUrl.value = form.value.avatar;

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
const resetPwd = () => {
  form.value.password = defaultPwd;
};
const confirmSave = async (cb?: Function) => {
  try {
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
      if (form.value.avatarFile) {
        const res: any = await uploadFile({ file: form.value.avatarFile });
        if (res?.fileName) params.avatar = res.fileName;
        delete params["avatarFile"];
      }

      const api = params.id ? editEmployee : createEmployee;
      await api(params);
      ElMessage({
        type: "success",
        message: "保存成功",
      });
      cb && cb();
    }
  } catch (e) {
    return false;
  }
};
const queryDepartmentOptions = async () => {
  const res = await getDepartmentList();
  if ((res as any)?.data?.length) {
    departmentOptions.value = buildDepartmentTree((res as any)?.data || []);
  }
};
const queryRoleOptions = async () => {
  const res = await getRoleList();
  if ((res as any)?.data?.length) {
    roleOptions.value = (res as any).data;
  }
};
onMounted(() => {
  queryDepartmentOptions();
  queryRoleOptions();
});
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
