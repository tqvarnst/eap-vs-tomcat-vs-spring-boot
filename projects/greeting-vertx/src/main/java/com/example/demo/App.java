package com.example.demo;

import io.vertx.core.AbstractVerticle;
import io.vertx.core.json.JsonObject;
import io.vertx.ext.web.Router;
import io.vertx.ext.web.RoutingContext;
import io.vertx.ext.web.handler.StaticHandler;

import static io.vertx.core.http.HttpHeaders.CONTENT_TYPE;

public class App extends AbstractVerticle {

    static final String TEMPLATE = "Hello from Vert.x Fat JAR, %s!";

    @Override
    public void start() {

        Router router = Router.router(vertx);

        router.get("/").handler(this::greeting);

        vertx.createHttpServer().requestHandler(router::accept).listen(8080);

        System.out.println("THE HTTP APPLICATION HAS STARTED");
    }

    private void greeting(RoutingContext rc) {
        String name = rc.request().getParam("name");
        if (name == null) {
            name = "World";
        }

        JsonObject response = new JsonObject()
                .put("content", String.format(TEMPLATE, name));

        rc.response()
                .putHeader(CONTENT_TYPE, "application/json; charset=utf-8")
                .end(response.encode());
    }
}
