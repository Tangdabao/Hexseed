package com.st.bluenrgmesh.models.newmeshdata;

import java.io.Serializable;



public class AppKey implements Serializable {

    private String name;

    public String getName() { return this.name; }

    public void setName(String name) { this.name = name; }

    private int index;

    public int getIndex() { return this.index; }

    public void setIndex(int index) { this.index = index; }

    private String key;

    public String getKey() { return this.key; }

    public void setKey(String key) { this.key = key; }

    private String oldKey;

    public String getOldKey() { return this.oldKey; }

    public void setOldKey(String oldKey) { this.oldKey = oldKey; }

    private int boundNetKey;

    public int getBoundNetKey() { return this.boundNetKey; }

    public void setBoundNetKey(int boundNetKey) { this.boundNetKey = boundNetKey; }
}
