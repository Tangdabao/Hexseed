package com.st.bluenrgmesh.models.newmeshdata;

import java.io.Serializable;
import java.util.ArrayList;



public class Model implements Serializable {

    private String modelId;

    public String getModelId() { return this.modelId; }

    public void setModelId(String modelId) { this.modelId = modelId; }

    private ArrayList<String> subscribe;

    public ArrayList<String> getSubscribe() { return this.subscribe; }

    public void setSubscribe(ArrayList<String> subscribe) { this.subscribe = subscribe; }

    private Publish publish;

    public Publish getPublish() { return this.publish; }

    public void setPublish(Publish publish) { this.publish = publish; }

    private String bind;

    public String getBind() { return this.bind; }

    public void setBind(String bind) { this.bind = bind; }
}
