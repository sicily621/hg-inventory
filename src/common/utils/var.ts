const htmlID = document.getElementsByTagName('html')[0]?.id;
const box = document.getElementById(htmlID);
const boxStyle = window.getComputedStyle(box as Element);

export const getCssVar = (key: string) => boxStyle.getPropertyValue(key);

