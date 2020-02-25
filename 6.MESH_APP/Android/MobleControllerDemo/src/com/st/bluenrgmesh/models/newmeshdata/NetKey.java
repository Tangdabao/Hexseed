package com.st.bluenrgmesh.models.newmeshdata;

import java.io.Serializable;



public class NetKey implements Serializable {

    private String name;

    public String getName() { return this.name; }

    public void setName(String name) { this.name = name; }

    private int index;

    public int getIndex() { return this.index; }

    public void setIndex(int index) { this.index = index; }

    private int phase;

    public int getPhase() { return this.phase; }

    public void setPhase(int phase) { this.phase = phase; }

    private String key;

    public String getKey() { return this.key; }

    public void setKey(String key) { this.key = key; }

    private String minSecurity;

    public String getMinSecurity() { return this.minSecurity; }

    public void setMinSecurity(String minSecurity) { this.minSecurity = minSecurity; }

    private String oldKey;

    public String getOldKey() { return this.oldKey; }

    public void setOldKey(String oldKey) { this.oldKey = oldKey; }
}
