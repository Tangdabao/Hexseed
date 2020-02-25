package com.st.bluenrgmesh.models.meshdata;

import java.io.Serializable;
import java.util.ArrayList;


public class Composition implements Serializable {

    private String cid;

    public String getCid() { return this.cid; }

    public void setCid(String cid) { this.cid = cid; }

    private String pid;

    public String getPid() { return this.pid; }

    public void setPid(String pid) { this.pid = pid; }

    private String vid;

    public String getVid() { return this.vid; }

    public void setVid(String vid) { this.vid = vid; }

    private String crpl;

    public String getCrpl() { return this.crpl; }

    public void setCrpl(String crpl) { this.crpl = crpl; }

    private Features features;

    public Features getFeatures() { return this.features; }

    public void setFeatures(Features features) { this.features = features; }

    private ArrayList<Element> elements;

    public ArrayList<Element> getElements() { return this.elements; }

    public void setElements(ArrayList<Element> elements) { this.elements = elements; }

}
