/**
 * *****************************************************************************
 *
 * @file SensorModelCallbacks.java
 * @author BLE Mesh Team
 * @version V1.08.000
 * @date 15-October-2018
 * @brief User Application file
 * *****************************************************************************
 * @attention <h2><center>&copy; COPYRIGHT(c) 2017 STMicroelectronics</center></h2>
 * <p>
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 3. Neither the name of STMicroelectronics nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 * <p>
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * <p>
 * BlueNRG-Mesh is based on Motorola’s Mesh Over Bluetooth Low Energy (MoBLE)
 * technology. STMicroelectronics has done suitable updates in the firmware
 * and Android Mesh layers suitably.
 * <p>
 * *****************************************************************************
 */

package com.st.bluenrgmesh.callbacks;

import com.msi.moble.ApplicationParameters;
import com.msi.moble.SensorModelClient;
import com.st.bluenrgmesh.MainActivity;
import com.st.bluenrgmesh.UserApplication;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.logger.LoggerConstants;

import java.util.ArrayList;

/**
 * Created by sharma01 on 10/9/2018.
 */

public class SensorModelCallbacks {

    public static int SENSOR_MODEL_CASE = 1;

    public static SensorModelClient.GetSensorStatusCallback mGetSensorStatusCallback = new SensorModelClient.GetSensorStatusCallback() {
        public void ongetSensorStatus(boolean timeout,ArrayList<ApplicationParameters.SensorDataFormat> format,
                                      ArrayList<ApplicationParameters.SensorDataLength> length,
                                      ArrayList<ApplicationParameters.SensorDataPropertyId> propertyIds,
                                      ArrayList<String> Sensordata) {

            if(timeout){
                ((MainActivity)Utils.contextMainActivity).mUserDataRepository.getNewDataFromRemote("GetSensor Status Callback==>"+"timeout", LoggerConstants.TYPE_RECEIVE);
                UserApplication.trace("Timeout Occurs");
                Utils.updateSensorEvents(null, SENSOR_MODEL_CASE, 0);
            } else{

                ApplicationParameters.SensorDataPropertyId mPropertyId = null;
                ((MainActivity)Utils.contextMainActivity).mUserDataRepository.getNewDataFromRemote("GetSensor Status Callback==>"+"Success", LoggerConstants.TYPE_RECEIVE);

                Utils.DEBUG("sensorDataFormat : " + format);
                Utils.DEBUG("sensorDataLength : " + length);
                Utils.DEBUG("sensorDataPropertyId : " + propertyIds);
                Utils.DEBUG("sensorDataData : " + Sensordata);

                for(ApplicationParameters.SensorDataFormat fmt : format) {
                    UserApplication.trace("Application Parameters: format " + fmt);
                }

                for(ApplicationParameters.SensorDataLength slen : length) {
                    UserApplication.trace("Application  Parameters: slen " +(slen));
                }

                int propertyId = -1;
                for(ApplicationParameters.SensorDataPropertyId mpropid : propertyIds) {
                    mPropertyId = mpropid;
                    if(propertyIds.size() == 1)
                    {
                        //for temperature and pressure single event
                        String[] propertyArray = String.valueOf(mPropertyId).split(" ");
                        propertyId = Integer.parseInt(propertyArray[0]);
                        UserApplication.trace("Application  Parameters: propertyId " +(mpropid));
                    }

                }

                ArrayList<String> sensorData = new ArrayList<>();
                String data = "";
                String separatorStr = "New";

                for (int i = 0; i < Sensordata.size(); i++) {
                    UserApplication.trace("Application  Parameters: SensorData " +(Sensordata.get(i)));
                    //char[] chars = sdat.toCharArray();
                    CharSequence seq = " ";
                    String[] splited = Sensordata.get(i).split("\\s+");
                    String str1 = "";
                    String str2 = "";
                    for (int j = 0; j < splited.length; j++) {

                        if (j == 1) {
                            str1 = Utils.getStringFromHashValue(splited[j]);
                       
                        } else if (j == 2) {
                            str2 = Utils.getStringFromHashValue(splited[j]);
                        }
                    }
                    sensorData.add(String.valueOf(Utils.convertHexToFloat(str2 + str1)));
                    String sensorValues = String.valueOf(Utils.convertHexToFloat(str2 + str1));
                    //mListener.setSensorData(sensorValues);
                    data = data + separatorStr + sensorValues;
                }

                Utils.updateSensorEvents(data, SENSOR_MODEL_CASE, propertyId);
               
            }
        }
    };

}
