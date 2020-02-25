package com.st.bluenrgmesh.models.meshdata;

import java.io.Serializable;
import java.util.ArrayList;


public class Configuration implements Serializable {

    private ArrayList<NetKey2> netKeys;

    public ArrayList<NetKey2> getNetKeys() { return this.netKeys; }

    public void setNetKeys(ArrayList<NetKey2> netKeys) { this.netKeys = netKeys; }

    private ArrayList<AppKey2> appKeys;

    public ArrayList<AppKey2> getAppKeys() { return this.appKeys; }

    public void setAppKeys(ArrayList<AppKey2> appKeys) { this.appKeys = appKeys; }

    private NetworkTransmit networkTransmit;

    public NetworkTransmit getNetworkTransmit() { return this.networkTransmit; }

    public void setNetworkTransmit(NetworkTransmit networkTransmit) { this.networkTransmit = networkTransmit; }

    private int defaultTTL;

    public int getDefaultTTL() { return this.defaultTTL; }

    public void setDefaultTTL(int defaultTTL) { this.defaultTTL = defaultTTL; }

    private Features2 features;

    public Features2 getFeatures() { return this.features; }

    public void setFeatures(Features2 features) { this.features = features; }

    private RelayRetransmit relayRetransmit;

    public RelayRetransmit getRelayRetransmit() { return this.relayRetransmit; }

    public void setRelayRetransmit(RelayRetransmit relayRetransmit) { this.relayRetransmit = relayRetransmit; }


}
