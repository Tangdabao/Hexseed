package com.st.bluenrgmesh.models.newmeshdata;

import java.io.Serializable;
import java.util.ArrayList;


public class MeshRoot implements Serializable {

    private String $schema;

    public String getSchema() { return this.$schema; }

    public void setSchema(String $schema) { this.$schema = $schema; }

    private String meshUUID;

    public String getMeshUUID() { return this.meshUUID; }

    public void setMeshUUID(String meshUUID) { this.meshUUID = meshUUID; }

    private String meshName;

    public String getMeshName() { return this.meshName; }

    public void setMeshName(String meshName) { this.meshName = meshName; }

    private String version;

    public String getVersion() { return this.version; }

    public void setVersion(String version) { this.version = version; }

    private String timestamp;

    public String getTimestamp() { return this.timestamp; }

    public void setTimestamp(String timestamp) { this.timestamp = timestamp; }

    private ArrayList<Provisioner> provisioners;

    public ArrayList<Provisioner> getProvisioners() { return this.provisioners; }

    public void setProvisioners(ArrayList<Provisioner> provisioners) { this.provisioners = provisioners; }

    private ArrayList<NetKey> netKeys;

    public ArrayList<NetKey> getNetKeys() { return this.netKeys; }

    public void setNetKeys(ArrayList<NetKey> netKeys) { this.netKeys = netKeys; }

    private ArrayList<AppKey> appKeys;

    public ArrayList<AppKey> getAppKeys() { return this.appKeys; }

    public void setAppKeys(ArrayList<AppKey> appKeys) { this.appKeys = appKeys; }

    private ArrayList<Node> nodes;

    public ArrayList<Node> getNodes() { return this.nodes; }

    public void setNodes(ArrayList<Node> nodes) { this.nodes = nodes; }

    private ArrayList<Group> groups;

    public ArrayList<Group> getGroups() { return this.groups; }

    public void setGroups(ArrayList<Group> groups) { this.groups = groups; }

    private String scenes;

    public String getScenes() { return this.scenes; }

    public void setScenes(String scenes) { this.scenes = scenes; }

}
