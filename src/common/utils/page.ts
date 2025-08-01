//计算表格序号的
export const indexMethod = (page: number, size: number) => {
  return (index: number) => {
    return page * size + index + 1;
  };
};
