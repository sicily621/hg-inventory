import dayjs from "dayjs";

const INVALID_DATE = "N/A";

/** 格式化日期时间 */
export function formatDateTime(
  datetime: string | number | Date = "",
  template: string = "YYYY-MM-DD HH:mm:ss",
) {
  const day = dayjs(datetime);
  return day.isValid() ? day.format(template) : INVALID_DATE;
}

export function formatTimeToString() {
  return dayjs(new Date()).format("YYYYMMDDHHmmssSSS");
}

export const formatSecondsToDuration = (totalSeconds: number) => {
  if (totalSeconds < 60) {
    return `0分`;
  }
  const secondsPerDay = 86400;
  const secondsPerHour = 3600;
  const secondsPerMinute = 60;

  const days = Math.floor(totalSeconds / secondsPerDay);
  const remainingSecondsAfterDays = totalSeconds % secondsPerDay;
  const hours = Math.floor(remainingSecondsAfterDays / secondsPerHour);
  const remainingSecondsAfterHours = remainingSecondsAfterDays % secondsPerHour;
  const minutes = Math.floor(remainingSecondsAfterHours / secondsPerMinute);

  const parts: string[] = [];
  if (days > 0) {
    parts.push(`${days}天`);
  }
  if (hours > 0) {
    parts.push(`${hours}时`);
  }
  if (minutes > 0) {
    parts.push(`${minutes}分`);
  }

  return parts.join("");
};