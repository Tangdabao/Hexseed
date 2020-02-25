package com.st.bluenrgmesh.models.newmeshdata;

import java.io.Serializable;
import java.util.ArrayList;


public class Element implements Serializable {
    private String unicastAddress;

    public String getUnicastAddress() { return this.unicastAddress; }

    public void setUnicastAddress(String unicastAddress) { this.unicastAddress = unicastAddress; }

    private int index;

    public int getIndex() { return this.index; }

    public void setIndex(int index) { this.index = index; }

    private ArrayList<Model> models;

    public ArrayList<Model> getModels() { return this.models; }

    public void setModels(ArrayList<Model> models) { this.models = models; }

    private String name;

    public String getName() { return this.name; }

    public void setName(String name) { this.name = name; }
}
