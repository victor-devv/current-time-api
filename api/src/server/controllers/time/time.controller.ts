import { Request, Response } from "express";
import {
  controller,
  httpGet,
  request,
  response
} from "inversify-express-utils";
import { BaseController } from "../base";
import moment from "moment-timezone";

@controller("/time")
export default class TimeController extends BaseController {
  /**
   * Returns the current time
   * @param req
   * @param res
   */
  @httpGet("/")
  async getUser(@request() req: Request, @response() res: Response) {
    try {
      const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
      const now = moment().tz(timezone);

      const data = {
        utc_offset: now.format("Z"),
        timezone: timezone,
        day_of_week: now.day(),
        day_of_year: now.dayOfYear(),
        datetime: now.format(),
        utc_datetime: now.utc().format(),
        unixtime: now.unix(),
        raw_offset: now.utcOffset() * 60,
        week_number: now.week(),
        dst: now.isDST(),
        abbreviation: now.format("z"),
        dst_offset: now.isDST() ? 3600 : 0,
        dst_from: now.isDST() ? null : null,
        dst_until: now.isDST() ? null : null,
        client_ip: req.ip
      };
      
      this.handleSuccess(req, res, data);
    } catch (err) {
      this.handleError(req, res, err);
    }
  }
}
