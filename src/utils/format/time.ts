import dayjs from 'dayjs'
import utc from 'dayjs/plugin/utc'
import timezone from 'dayjs/plugin/timezone'
import { isNumber } from 'lodash-es'

dayjs.extend(utc)
dayjs.extend(timezone)

const format = 'YYYY-MM-DD HH:mm:ss'
const systemTimezone = 'Asia/Shanghai'

const timePattern = /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/

export default (time: number | string, utc?: boolean) => {
  if (isNumber(time)) {
    return dayjs(time).format(format)
  }
  else if (timePattern.test(time)) {
    if (utc)
      return dayjs(time).utc(true).local().format(format)
    else
      return dayjs(time).tz(systemTimezone, true).local().format(format)
  }
  else {
    return time
  }
}
