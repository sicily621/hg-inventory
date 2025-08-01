<template>
  <div class="flex-1 d-flex m-l-20 m-t-20">
    <el-form
      ref="formRef"
      :model="form"
      :rules="rules"
      label-position="top"
      class="d-flex relative flex-1"
      label-width="120px"
    >
      <div class="flex-1 d-flex">
        <div class="w-296">
          <el-form-item :label="i18nM('space.label.name')" prop="building.name">
            <el-input
              v-model="form.building.name"
              class="flex-1"
              :placeholder="i18nM('space.placeholder.inputName')"
              maxlength="32"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.description')"
            prop="building.description"
          >
            <el-input
              class="flex-1 m-r-10 ipt_desc"
              v-model="form.building.description"
              type="textarea"
              maxlength="64"
              :placeholder="i18nM('space.placeholder.inputDescription')"
            ></el-input>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.buildingStructure')"
            prop="building.buildingType"
          >
            <el-radio-group v-model="form.building.buildingType">
              <el-radio
                :label="item.value"
                v-for="item in buildingStructureOptions"
                >{{ item.label }}</el-radio
              >
            </el-radio-group>
          </el-form-item>
          <el-form-item
            class="d-flex"
            :label="i18nM('space.label.type')"
            prop="building.buildingTypeId"
          >
            <el-select
              class="flex-1 m-r-20"
              v-model="buildingType"
              :placeholder="i18nM('space.placeholder.selectType')"
              @change="changeBuildingType"
            >
              <el-option
                v-for="item in buildingTypeOptions"
                :key="item.id"
                :label="item.cnName"
                :value="item.id"
              >
              </el-option>
            </el-select>
            <el-select
              class="flex-1 m-r-10"
              v-model="form.building.buildingTypeId"
              :placeholder="i18nM('space.placeholder.selectSubType')"
            >
              <el-option
                v-for="item in subBuildingTypeOptions"
                :key="item.id"
                :label="item.cnName"
                :value="item.id"
              >
              </el-option>
            </el-select>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.externalCode')"
            prop="building.userCode"
          >
            <el-input
              v-model="form.building.userCode"
              class="flex-1"
              :placeholder="i18nM('space.placeholder.inputCode')"
            >
            </el-input>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.aboveGroundFloors')"
            prop="building.floorNumber"
          >
            <el-input
              v-model.number="form.building.floorNumber"
              class="flex-1"
              :placeholder="i18nM('space.placeholder.inputAboveGroundFloors')"
            >
            </el-input>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.undergroundFloors')"
            prop="building.undergroundNumber"
          >
            <el-input
              v-model.number="form.building.undergroundNumber"
              class="flex-1"
              :placeholder="i18nM('space.placeholder.inputUndergroundFloors')"
            >
            </el-input>
          </el-form-item>
        </div>
        <div class="w-296 m-l-60">
          <el-form-item
            :label="i18nM('space.label.areaCovered')"
            prop="building.areaCovered"
          >
            <el-input
              v-model="form.building.areaCovered"
              class="flex-1"
              :placeholder="i18nM('space.placeholder.inputAreaCovered')"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.buildUpArea')"
            prop="building.buildUpArea"
          >
            <el-input
              v-model="form.building.buildUpArea"
              class="flex-1"
              :placeholder="i18nM('space.placeholder.inputBuildUpArea')"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.heatingArea')"
            prop="building.heatingArea"
          >
            <el-input
              v-model="form.building.heatingArea"
              class="flex-1"
              :placeholder="i18nM('space.placeholder.inputHeatingArea')"
              required
            >
            </el-input>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.buildingHeight')"
            prop="building.buildingHeight"
          >
            <el-input
              v-model="form.building.buildingHeight"
              class="flex-1"
              :placeholder="i18nM('space.placeholder.inputBuildingHeight')"
            ></el-input>
          </el-form-item>
        </div>

        <div class="m-l-80">
          <el-form-item
            :label="i18nM('space.label.mapType')"
            prop="map.mapType"
          >
            <el-select
              v-model="map.mapType"
              :placeholder="i18nM('space.placeholder.selectType')"
              class="flex-1"
              disabled
            >
              <el-option
                v-for="item in mapTypeOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              >
              </el-option>
            </el-select>
          </el-form-item>
          <el-form-item
            class="flex-column"
            :label="i18nM('space.label.buildingMap') + ' (可批量上传)'"
            prop="map.mapFilePath"
          >
            <div class="d-flex">
              <el-upload
                :before-upload="beforeUpload"
                accept=".FBX,.zip"
                class="h-30"
              >
                <el-button type="primary" class="upload-btn fz12 m-r-20"
                  >上传</el-button
                >
              </el-upload>
              <el-button
                type="primary"
                class="fz12"
                @click="loadMap"
                v-if="mapFiles.length > 0"
                >查看</el-button
              >
            </div>
            <div class="el-upload__tip">
              <el-text class="fz12" type="danger">{{ messageUpload }}</el-text>
            </div>
          </el-form-item>

          <el-form-item class="w-full" v-if="mapFiles.length > 0">
            <div class="map_files w-full">
              <el-scrollbar class="h-full">
                <div
                  class="d-flex justify-content-between align-items-center file-item"
                  v-for="(file, index) in mapFiles"
                >
                  <el-text default class="flex-1 overflow-spot">{{
                    file.name
                  }}</el-text>
                  <div class="d-flex flex-center">
                    <el-upload
                      :before-upload="beforeUpload2"
                      accept=".FBX,.fbx"
                      class="fz16 m-r-16 pointer flex flex-center"
                    >
                      <el-icon>
                        <Edit @click="editMapFile(index)" />
                      </el-icon>
                    </el-upload>
                    <el-icon
                      class="fz16 pointer"
                      text
                      @click="removeMapFile(file, index)"
                    >
                      <Delete />
                    </el-icon>
                  </div>
                </div>
              </el-scrollbar>
            </div>
          </el-form-item>
          <el-form-item
            class="flex-column"
            :label="i18nM('space.label.floorMap') + ' (可批量上传)'"
            prop="floorMap.mapFilePath"
          >
            <div class="d-flex">
              <el-upload
                :before-upload="beforeUpload3"
                class="h-30"
                accept=".zip"
              >
                <el-button type="primary" class="upload-btn fz12 m-r-20"
                  >上传</el-button
                >
              </el-upload>
              <el-button
                type="primary"
                class="fz12"
                @click="loadFloorMap"
                v-if="mapFiles.length > 0"
                >查看</el-button
              >
              <div class="m-b-10 m-l-20" v-if="!props.data?.id">
                <el-checkbox
                  v-model="initFloor"
                  label="初始化楼层"
                  class="m-l-10"
                />
              </div>
            </div>
            <div class="el-upload__tip">
              <el-text class="fz12" type="danger">{{ messageUpload3 }}</el-text>
            </div>
          </el-form-item>
        </div>
        <div class="m-l-60 w-296 m-r-90">
          <el-form-item :label="i18nM('space.label.logo')" prop="building.logo">
            <Upload
              @fileChange="fileLogoChange($event)"
              :imgPath="
                form.building.logo === 'defaultBuildLogo.png'
                  ? defaultBuildLogoImg
                  : form.building.logo
              "
              :accept="UploadType.commonImg"
            ></Upload>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.image')"
            prop="building.image"
          >
            <Upload
              :imgStyle="imgStyle"
              @fileChange="fileImageChange($event)"
              :imgPath="
                form.building.image === 'defaultBuild.png'
                  ? defaultBuildImg
                  : form.building.image
              "
              :accept="UploadType.commonImg"
            ></Upload>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.thirdPartyMap')"
            prop="thirdMap.mapFactory"
          >
            <el-select
              v-model="thirdMap.mapFactory"
              :placeholder="i18nM('space.placeholder.selectType')"
              class="w-full"
            >
              <el-option
                v-for="item in mapFactoryTypeOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              >
              </el-option>
            </el-select>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.url')"
            prop="thirdMap.mapFactory"
          >
            <el-input
              v-model="thirdMap.mapUrl"
              class="w-full"
              :placeholder="i18nM('space.placeholder.inputUrl')"
              maxlength="255"
            >
            </el-input>
          </el-form-item>
          <el-form-item
            :label="i18nM('space.label.mapNo')"
            prop="thirdMap.mapFactory"
          >
            <el-input
              v-model="thirdMap.mapNo"
              class="w-full"
              :placeholder="i18nM('space.placeholder.inputMapNumber')"
              maxlength="32"
            >
            </el-input>
          </el-form-item>
        </div>
      </div>
      <div class="code-wrap" v-if="codeShow">
        <qrcode-vue
          :value="codeValue"
          :level="level"
          :render-as="renderAs"
          :size="size"
        />
      </div>
    </el-form>
    <zModel
      ref="mapZModelRef"
      :style="{ width: '100%', height: '100%' }"
      :custom-model-title="building.name"
      :noConfirmBtnFlag="true"
      @confirm="() => {}"
    >
      <div class="flex-1 d-flex w-full h-full relative">
        <div class="tree-wrap" v-if="showFloorMap">
          <tree
            :data="treeData"
            :expandedKeys="spaceExpandedKeys"
            :currentNodeKey="spaceCurrentNode?.id"
            ref="treeRef"
            @changeNode="changeNode($event)"
            :placeholder="i18nM('space.placeholder.inputSpaceName')"
            :propsObj="defaultProps"
            :searchFlag="true"
          >
          </tree>
        </div>

        <Map ref="mapRef" class="flex-1" />
      </div>
    </zModel>
  </div>
</template>
<script setup lang="ts">
import { ref, reactive, onMounted, nextTick, watch } from "vue";
import tree from "@static/elementUI/tree/tree.vue";
import type { Ref } from "vue";
import {
  Building,
  createBuilding,
  buildingCreateProps,
  MapType,
  BuildingMap,
  getBuildingMapGetByBuildingId,
  BuildingForm,
  createBuildingMap,
  BuildingType,
  buildingTypesTreeNode,
  editBuildingMap,
  deleteBuildingMap,
} from "@functions/serviceCenter/space-management/api/building";
import {
  floorsBatchInsert,
  floorsMapsBatchInsert,
  floorsPage,
  getFloorMapsGetByFloorId,
  floorTreeNode,
  FloorListParams,
} from "@functions/serviceCenter/space-management/api/floor";
import { buildingFindTypesTree } from "@functions/serviceCenter/common-base/api/building";
import {
  ThirdMap,
  MapFactory,
  queryThirdMapParams,
  deleteThirdMapParams,
  createThirdMap,
  queryThirdMap,
  deleteThirdMap,
} from "@functions/serviceCenter/space-management/api/thirdMap";
import Upload from "@static/elementUI/upload/upload.vue";
import defaultBuildImg from "@static/images/defaultBuild.png";
import defaultBuildLogoImg from "@static/images/defaultBuildLogoImg.png";
import { zrem } from "@static/js/theme/zrem";
import { ElMessage, type FormRules } from "element-plus";
import QrcodeVue from "qrcode.vue";
import type { Level, RenderAs } from "qrcode.vue";
import zModel from "@static/components/zModel/zModel.vue";
import Map from "@static/components/map/index.vue";
import { UploadType } from "@static/js/common/enum";
import { useI18n } from "vue-i18n";
const { locale } = useI18n();
const i18nM = window.$i18nM;

const mapRef = ref();

const formRef = ref();
const imgStyle = { width: zrem(360), height: zrem(180) };
const props = defineProps(buildingCreateProps);
const mapZModelRef = ref();
const files = ref<string[]>([]);
const initFloor = ref<boolean>(false);
const showFloorMap = ref<boolean>(false);

//建筑类型
const buildingType = ref("");
const buildingTypeOptions = ref<buildingTypesTreeNode[]>([]);
const subBuildingTypeOptions = ref<buildingTypesTreeNode[]>([]);

//建筑
const building = ref<Building>({
  projectId: Number(""),
  parkId: Number(""),
  name: "",
  description: "",
  areaCovered: parseFloat("0.0"),
  buildUpArea: parseFloat("0.0"),
  buildingHeight: parseFloat("0.0"),
  buildingType: BuildingType.isolated,
  buildingTypeId: Number(""),
  heatingArea: parseFloat("0.0"),
  undergroundNumber: Number(""),
  floorNumber: Number(""),
  image: "defaultBuild.png",
  image_file: null,
  logo: "defaultBuildLogo.png",
  logo_file: null,
  userCode: "",
  code: "",
});
//地图
const map: Ref<BuildingMap> = ref({
  buildingId: Number(""),
  projectId: Number(""),
  parkId: Number(""),
  mapFilePath_file: null,
  mapType: MapType.FBX,
  name: "",
});

const floorMap: Ref<BuildingMap> = ref({
  buildingId: Number(""),
  projectId: Number(""),
  parkId: Number(""),
  mapFilePath_file: null,
  mapType: MapType.FBX,
  name: "",
});
//三方地图
const thirdMap = ref<ThirdMap>({
  projectId: Number(""),
  mapFactory: 0,
  spaceType: 2,
  spaceId: Number(""),
  mapUrl: "",
  mapNo: "",
});

//三方地图厂家类型
const mapFactoryTypeOptions = ref([
  {
    value: MapFactory.Supermap,
    label: i18nM("space.enumValue.supermap"),
  },
  {
    value: MapFactory.Map_51,
    label: i18nM("space.enumValue.map51"),
  },
]);

//表单
const form = ref<BuildingForm>({
  building: building.value,
  map: map.value,
  floorMap: floorMap.value,
  thirdMap: thirdMap.value,
});

const mapFiles = ref<BuildingMap[]>([]);
const deleteMapFiles = ref<BuildingMap[]>([]);
//二维码
const codeValue = ref("");
const codeShow = ref(true);
const level = ref<Level>("M");
const renderAs = ref<RenderAs>("svg");
const size = ref(120);

//建筑构造类型
const buildingStructureOptions = ref([
  {
    value: BuildingType.isolated,
    label: i18nM("space.enumValue.detached"),
  },
  {
    value: BuildingType.unIsolated,
    label: i18nM("space.enumValue.nonDetached"),
  },
]);
//地图类型
const mapTypeOptions = ref([
  {
    value: MapType.FBX,
    label: "FBX",
  },
  {
    value: MapType.JSON,
    label: "JSON",
  },
  {
    value: MapType.OBJ,
    label: "OBJ",
  },
  {
    value: MapType.GLB,
    label: "GLB",
  },
  {
    value: MapType.GLTF,
    label: "GLTF",
  },
]);

//合并props
building.value = Object.assign(building.value, props.data);
building.value.parkId = Number(props?.parkId ?? "");
map.value.buildingId = floorMap.value.buildingId = props?.data?.id ?? 0;
map.value.parkId = floorMap.value.parkId = Number(props?.parkId ?? 0);
codeShow.value = !!props?.data?.code;
codeValue.value = `${props?.data?.projectId}.${props?.data?.code}`;

//建筑类型下拉选中值发生变化时触发
const changeBuildingType = (val: any) => {
  const selected = buildingTypeOptions?.value.filter(
    (option: any) => option.id == val
  );
  subBuildingTypeOptions.value = selected[0]?.subList ?? [];
  form.value.building.buildingTypeId = Number(
    subBuildingTypeOptions?.value[0]?.id ?? 0
  );
};
//编辑或新建时选中建筑类型
const selectBuildingType = (res: any) => {
  buildingTypeOptions.value = res?.data?.subList ?? [];
  const selectParentOption = buildingTypeOptions.value.find((options: any) => {
    const { subList } = options;
    const option = subList!.find((subOption: any, index: number) => {
      if (props?.data?.id) {
        //编辑选中传入建筑的类型
        return subOption.id == building.value.buildingTypeId;
      } else {
        //新建默认选中第一个类型
        building.value.buildingTypeId = subOption.id;
        return index == 0;
      }
    });
    if (option) return true;
  });
  subBuildingTypeOptions.value = selectParentOption?.subList ?? [];
  buildingType.value = selectParentOption?.id ?? "";
};
// 校验规则
let validatorNumber = (rule: any, value: string, callback: Function) => {
  if (!rule.required && value.length === 0) callback();
  if (value.length === 0) return callback(new Error("不能为空"));
  if (isNaN(Number(value))) return callback(new Error("请输入数字"));
  let reg = /((^[0-9]\d*)|^0)(\.\d{0,2}){0,1}$/;
  if (!reg.test(value)) return callback(new Error("请输入两位小数"));
  callback();
};
const validatorPosInteger = (rule: any, value: string, callback: Function) => {
  if (!rule.required && !value) callback();
  if (value === "") return callback(new Error("不能为空"));
  if (isNaN(Number(value))) return callback(new Error("请输入数字"));
  if (Number(value) < 0) return callback(new Error("不能为负数"));
  callback();
};

const rules = reactive({
  building: {
    name: [{ required: true, message: "不能为空" }],
    areaCovered: [
      {
        required: true,
        validator: validatorNumber,
        trigger: "blur",
      },
    ],
    buildUpArea: [
      {
        required: true,
        validator: validatorNumber,
        trigger: "blur",
      },
    ],
    heatingArea: [
      {
        required: true,
        validator: validatorNumber,
        trigger: "blur",
      },
    ],
    floorNumber: [
      {
        required: true,
        trigger: "blur",
        validator: validatorPosInteger,
      },
    ],
    undergroundNumber: [
      {
        required: true,
        trigger: "blur",
        validator: validatorPosInteger,
      },
    ],
    buildingHeight: [
      { required: true, validator: validatorNumber, trigger: "blur" },
    ],
  },
}) as FormRules;
//上传地图
const messageUpload = ref("");

//重命名FBX
const renameFile = (file: File) => {
  const type = file.name.substring(file.name.lastIndexOf(".") + 1);
  if (!["FBX", "fbx"].includes(type)) return file;
  const index = mapFiles.value.findIndex((item: any) => !item.id);
  const newFileName = `${form.value.map.buildingId}_${
    index === -1 ? mapFiles.value.length + 1 : index + 1
  }.${type}`;
  const newFile = new File([file], newFileName, {
    type: file.type,
    lastModified: file.lastModified,
  });
  return newFile;
};
const beforeUpload = (file: File) => {
  var type = file.name.substring(file.name.lastIndexOf(".") + 1);
  const FbxTypes = ["FBX", "fbx"];
  const types = ["zip", ...FbxTypes];
  if (!types.includes(type)) {
    messageUpload.value = "上传文件只能是 zip、FBX格式!";
    return false;
  }

  if (FbxTypes.includes(type)) {
    form.value.map.name = file.name;
    const index = mapFiles.value.findIndex((item: any) => !item.id);
    if (index === -1) mapFiles.value.push(form.value.map);
  }
  form.value.map.mapFilePath_file = file;

  messageUpload.value = "";
  return false;
};

const currentEditMapFileIndex = ref(-1);
//替换地图文件
const beforeUpload2 = (file: File) => {
  var type = file.name.substring(file.name.lastIndexOf(".") + 1);
  const types = ["FBX", "fbx"];
  if (!types.includes(type)) {
    messageUpload.value = "上传文件只能是 FBX、fbx格式!";
    return false;
  }

  if (types.includes(type)) {
    const currentMapFile = mapFiles.value[currentEditMapFileIndex.value];
    const newFileName = `${form.value.map.buildingId}_${
      currentEditMapFileIndex.value + 1
    }.${type}`;
    const newFile = new File([file], newFileName, {
      type: file.type,
      lastModified: file.lastModified,
    });
    currentMapFile.mapFilePath_file = newFile;
    currentMapFile.name = file.name;
    currentMapFile.edit = true;
  }
  messageUpload.value = "";
  currentEditMapFileIndex.value = -1;
  return false;
};

const messageUpload3 = ref("");
const beforeUpload3 = (file: File) => {
  var type = file.name.substring(file.name.lastIndexOf(".") + 1);
  const types = ["zip"];
  if (!types.includes(type)) {
    messageUpload3.value = "上传文件只能是zip格式!";
  } else {
    form.value.floorMap.mapFilePath_file = file;
  }
  return false;
};
const fileLogoChange = (e: any) => {
  form.value.building.logo_file = e;
  form.value.building.logo = "";
};
const fileImageChange = (e: any) => {
  form.value.building.image_file = e;
};

//查看地图
const loadMap = () => {
  showFloorMap.value = false;
  mapZModelRef.value.openCustomModel();

  nextTick(() => {
    files.value = mapFiles.value.map(
      (file: BuildingMap) => file.mapFilePath || ""
    );
    mapRef.value?.load(files.value);
  });
};

//查看楼层地图
const loadFloorMap = () => {
  if (!props?.data) return;
  showFloorMap.value = true;
  mapZModelRef.value.openCustomModel();
  getFloorTreeData();
};

//删除地图文件
const removeMapFile = (file: BuildingMap, index: number) => {
  mapFiles.value.splice(index, 1);
  if (file.id) {
    deleteMapFiles.value.push(file);
  } else {
    map.value.mapFilePath_file = null;
  }
};

//编辑地图文件
const editMapFile = (index: number) => {
  currentEditMapFileIndex.value = index;
};

//批量编辑地图文件
const editMapFiles = () => {
  const editMaps: BuildingMap[] = mapFiles.value
    .filter((file: any) => {
      return file.id && file.edit;
    })
    .map((file: any) => {
      delete file["edit"];
      return file;
    });

  type FormDataEntry = [string, string | Blob | BufferSource | FormData];
  const formData = new FormData() as unknown as {
    append: (...args: FormDataEntry) => void;
  };
  editMaps.forEach((map: BuildingMap, index: number) => {
    for (let key in map) {
      if (map.hasOwnProperty(key)) {
        formData.append(`maps[${index}].${key}`, (map as any)[key]);
      }
    }
  });
  if (editMaps.length > 0) editBuildingMap(formData, () => {});
};

//批量删除地图文件
const removeMapFiles = () => {
  const deleteMapIds = deleteMapFiles.value.map((file: any) => file.id);
  if (deleteMapIds.length > 0)
    deleteBuildingMap(JSON.stringify(deleteMapIds), () => {});
};
//获取三方地图
const querySpaceThirdMap = (cb?: Function) => {
  const spaceId = map.value.buildingId;
  if (!spaceId) cb && cb();
  const params: queryThirdMapParams = {
    projectId: thirdMap.value.projectId,
    spaceId,
    spaceType: 2,
    mapFactory: thirdMap.value.mapFactory,
  };
  queryThirdMap(params, (res: any) => {
    const data = res?.data?.[0];
    if (data) {
      thirdMap.value = Object.assign(thirdMap.value, data);
    }
    cb && cb();
  });
};
//保存三方地图
const saveSpaceThirdMap = (cb?: Function) => {
  const { projectId, spaceId, spaceType } = thirdMap.value;
  const params: deleteThirdMapParams = {
    projectId,
    spaceId,
    spaceType,
  };
  deleteThirdMap(params, () => {
    let params = { ...thirdMap.value };
    delete params.id;
    createThirdMap(params, () => {
      cb && cb();
    });
  });
};

// 初始化楼层信息
const initBatchFloors = (res: Building) => {
  if (initFloor.value) {
    const params: any = {
      buildingId: res.id ?? "",
      floorNamePrefix: "F",
      floorNumber: res.floorNumber,
      image: "defaultFloor.png",
      parkId: props?.parkId ?? "",
      projectId: res.projectId ?? "",
      undergroundNamePrefix: "B",
      undergroundNumber: res.undergroundNumber,
    };
    floorsBatchInsert(params, () => {});
  }
};

//保存楼层地图
const saveFloorMaps = (res: Building) => {
  const params: any = {
    ...floorMap.value,
  };
  if (res) params.buildingId = res?.id ?? "";
  const isCreateFloorMap = !!params.mapFilePath_file;
  if (isCreateFloorMap) {
    floorsMapsBatchInsert(params, () => {});
  }
};

// 左侧空间树列表
const treeData: any = ref<floorTreeNode[]>([]);

//为过滤保留源数据
const rawParkData = ref<floorTreeNode[]>([]);

//左侧空间树列表props name当label
const defaultProps = {
  children: "children",
  label: "name",
};

//树列表默认展开楼层
const spaceExpandedKeys = ref<Array<number | string>>([0]);
//树列表当前选中楼层
const spaceCurrentNode = ref<floorTreeNode>({ id: 0, name: "", level: 0 });

//左侧空间树列表 选中节点变化触发
const changeNode = (data: any) => {
  loadFloorFBXList(data.id);
};

//获取楼层树数据
const getFloorTreeData = () => {
  const params: FloorListParams = {
    projectId: building.value.projectId ?? "",
    page: 0,
    size: 10000,
    parkId: building.value.parkId ?? 0,
    buildingId: building.value.id ?? 0,
  };
  floorsPage(params, (res: any) => {
    const { content } = res.data;
    rawParkData.value = content.map((data: any, index: number) => {
      const node = { id: data.id, name: data.name, level: 1, children: [] };
      if (index === 0) {
        loadFloorFBXList(node.id);
        spaceCurrentNode.value = node;
      }
      return node;
    });
    treeData.value = rawParkData.value;
  });
};

// 根据floorId获取FBX列表并加载
const loadFloorFBXList = (id: number) => {
  getFloorMapsGetByFloorId({ floorId: id }, (res: any) => {
    files.value = res.data.map((file: BuildingMap) => file.mapFilePath || "");
    mapRef.value?.load(files.value);
  });
};

const handleSaveSuccess = (res: any) => {
  formRef.value.resetFields();
  editMapFiles();
  removeMapFiles();
  initBatchFloors(res.data);
  saveFloorMaps(res.data);
  ElMessage({
    type: "success",
    message: "保存成功",
  });
};

//保存或新建
const confirmSave = (cb: Function) => {
  if (messageUpload.value.length || messageUpload3.value.length) return;
  formRef.value.validate((valid: boolean) => {
    if (valid) {
      const params = {
        ...form.value.building,
      };
      if (!props?.data?.id) {
        if (!params.image_file) {
          params.image = "defaultBuild.png";
        }
        if (!params.logo_file) {
          params.logo = "defaultBuildLogo.png";
        }
      }
      //保存建筑
      createBuilding(params, (res: any) => {
        map.value.buildingId = res.data.id;
        thirdMap.value.spaceId = res.data.id;
        const params = {
          ...map.value,
        };
        //是否上传地图包
        if (params.mapFilePath_file) {
          //保存地图
          params.mapFilePath_file = renameFile(params.mapFilePath_file);
          createBuildingMap(params, () => {
            saveSpaceThirdMap(() => {
              handleSaveSuccess(res);
              cb();
            });
          });
        } else {
          saveSpaceThirdMap(() => {
            handleSaveSuccess(res);
            cb();
          });
        }
      });
    }
  });
};

onMounted(() => {
  const project = window.$HyGlobal.getCurrentProject();
  if (project?.projects?.length) {
    const projectId = project.projects[0].projectId;
    building.value.projectId = projectId;
    map.value.projectId = floorMap.value.projectId = projectId;
    thirdMap.value.projectId = Number(projectId);
    //获取建筑类型下拉数据
    buildingFindTypesTree({}, (res: any) => {
      selectBuildingType(res);
    });
    if (props?.data?.id) {
      //获取建筑地图数据
      getBuildingMapGetByBuildingId(
        { buildingId: props.data.id },
        (res: any) => {
          mapFiles.value = res?.data;
          querySpaceThirdMap();
        }
      );
    }
  } else {
    ElMessage({
      type: "error",
      message: "未获取到项目信息",
    });
  }
});

watch(locale, () => {
  mapFactoryTypeOptions.value[0] = {
    value: MapFactory.Supermap,
    label: i18nM("space.enumValue.supermap"),
  };
  mapFactoryTypeOptions.value[1] = {
    value: MapFactory.Map_51,
    label: i18nM("space.enumValue.map51"),
  };
  buildingStructureOptions.value[0] = {
    value: BuildingType.isolated,
    label: i18nM("space.enumValue.detached"),
  };
  buildingStructureOptions.value[1] = {
    value: BuildingType.unIsolated,
    label: i18nM("space.enumValue.nonDetached"),
  };
});
defineExpose({
  confirmSave,
});
</script>
<style lang="scss" scoped>
@use "@static/css/common/size.scss" as *;
.map_files {
  border: zrem(1) solid var(--el-border-color);
  border-radius: zrem(8);
  padding: zrem(10);
  height: zrem(300);
  .file-item {
    line-height: zrem(30);
    height: zrem(30);
  }
}
.tree-wrap {
  position: absolute;
  left: 0;
  top: 0;
  width: zrem(200);
  height: 100%;
  z-index: 1;
  background-color: var(--el-fill-color-blank);
  padding: zrem(10);
}
.code-wrap {
  position: absolute;
  right: zrem(20);
  top: 0;
}
</style>
