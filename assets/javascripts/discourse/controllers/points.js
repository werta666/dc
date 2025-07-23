import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class PointsController extends Controller {
  @tracked userPoint = null;
  @tracked statistics = {};
  @tracked historyRecords = [];
  @tracked leaderboard = [];
  @tracked currentPage = 1;
  @tracked totalPages = 1;
  @tracked isLoadingHistory = false;
  @tracked isLoadingLeaderboard = false;
  @tracked leaderboardPeriod = "all_time";

  @action
  async loadHistory(page = 1) {
    this.isLoadingHistory = true;
    try {
      const result = await ajax("/checkin-plugin/points/history", {
        data: { page }
      });

      this.historyRecords = result.records;
      this.currentPage = result.pagination.current_page;
      this.totalPages = result.pagination.total_pages;
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isLoadingHistory = false;
    }
  }

  @action
  async loadLeaderboard(period = "all_time") {
    this.isLoadingLeaderboard = true;
    this.leaderboardPeriod = period;
    
    try {
      const result = await ajax("/checkin-plugin/points/leaderboard", {
        data: { period, limit: 20 }
      });

      this.leaderboard = result.leaderboard;
      this.currentUserRank = result.current_user_rank;
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isLoadingLeaderboard = false;
    }
  }

  @action
  nextPage() {
    if (this.currentPage < this.totalPages) {
      this.loadHistory(this.currentPage + 1);
    }
  }

  @action
  prevPage() {
    if (this.currentPage > 1) {
      this.loadHistory(this.currentPage - 1);
    }
  }

  get hasNextPage() {
    return this.currentPage < this.totalPages;
  }

  get hasPrevPage() {
    return this.currentPage > 1;
  }

  get leaderboardPeriods() {
    return [
      { key: "all_time", label: "All Time" },
      { key: "monthly", label: "This Month" },
      { key: "weekly", label: "This Week" }
    ];
  }
}
