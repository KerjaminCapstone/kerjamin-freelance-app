class ApiConfig {
  static String getMasterUrl() {
    return "https://kerjamin-api-v1.herokuapp.com/api";
  }

  static String getLoginUrl() {
    return getMasterUrl() + "/auth/login";
  }

  static String getOfferingListUrl() {
    return getMasterUrl() + "/freelancer/offerings";
  }

  static String getOfferingDetailUrl(String idOrder) {
    return getOfferingListUrl() + "/" + idOrder;
  }

  static String acceptOffering(String idOrder) {
    return getOfferingDetailUrl(idOrder) + "/confirm";
  }

  static String rejectOffering(String idOrder) {
    return getOfferingDetailUrl(idOrder) + "/reject";
  }

  static String getArrangement(String idOrder) {
    return getOfferingDetailUrl(idOrder) + "/arrangement";
  }

  static String PostTask(String idOrder) {
    return getOfferingDetailUrl(idOrder) + "/arrangement/task";
  }

  static String DeleteTask(String idOrder, idTask) {
    return getOfferingDetailUrl(idOrder) + "/arrangement/task/" + idTask;
  }

  static String getStatusOffering(String idOrder) {
    return getOfferingDetailUrl(idOrder) + "/status";
  }

  static String getHistoriesUrl() {
    return getMasterUrl() + "/freelancer/history";
  }

  static String getProfileUrl() {
    return getMasterUrl() + "/freelancer/me";
  }

  static String getUpdateAddressUrl() {
    return getProfileUrl() + "/update-address";
  }
}
