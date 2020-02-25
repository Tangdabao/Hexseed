package com.st.bluenrgmesh.models.newmeshdata;

import java.io.Serializable;


public class Publish implements Serializable {

    private String address;

    public String getAddress() { return this.address; }

    public void setAddress(String address) { this.address = address; }

    private int index;

    public int getIndex() { return this.index; }

    public void setIndex(int index) { this.index = index; }

    private int ttl;

    public int getTtl() { return this.ttl; }

    public void setTtl(int ttl) { this.ttl = ttl; }

    private int period;

    public int getPeriod() { return this.period; }

    public void setPeriod(int period) { this.period = period; }

    private String retransmit;

    public String getRetransmit() { return this.retransmit; }

    public void setRetransmit(String retransmit) { this.retransmit = retransmit; }

    private int credentials;

    public int getCredentials() { return this.credentials; }

    public void setCredentials(int credentials) { this.credentials = credentials; }
}
