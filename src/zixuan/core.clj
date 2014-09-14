(ns zixuan.core
  (:use ring.middleware.resource
        ring.middleware.content-type
        ring.middleware.not-modified
        ring.adapter.jetty
        compojure.core)
  (:require [clojure.tools.logging :as log]))

(defroutes app-routes
  (GET "/zz/health" []
    "OK"))

(defn wrap-web-access-logging
  [handler]
  (fn [{:keys [request-method remote-addr uri] :as request}]
    (let [request-start-at (System/currentTimeMillis)
          request-method (clojure.string/upper-case (name request-method))
          rsp (handler request)
          status (:status rsp)
          request-time (- (System/currentTimeMillis) request-start-at)
          params (:params request)]
      (log/info (str "__request__\t" remote-addr "\t" request-method "\t" status "\t" request-time " ms\t" uri "\t"
                  "params: " params))
      rsp
    )))

(def app
  (-> app-routes
      (wrap-resource "static/html")
      (wrap-content-type)
      (wrap-not-modified)
      (wrap-web-access-logging)))

(defn -main [ & args]
  (run-jetty app {:port 7000}))
