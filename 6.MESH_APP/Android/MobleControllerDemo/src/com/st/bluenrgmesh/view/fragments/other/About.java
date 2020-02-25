/**
 * *****************************************************************************
 *
 * @file About.java
 * @author BLE Mesh Team
 * @version V1.08.000
 * @date 15-October-2018
 * @brief About Application file
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

package com.st.bluenrgmesh.view.fragments.other;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.text.TextPaint;
import android.text.style.URLSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import com.msi.moble.mobleNetwork;
import com.st.bluenrgmesh.BuildConfig;
import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.Utils;
import com.st.bluenrgmesh.utils.AppDialogLoader;
import com.st.bluenrgmesh.view.fragments.base.BaseFragment;

/**
 * The type About.
 */
public class About extends BaseFragment {

    private TextView txtVersion, txtAbout;
    private String text, about;

    // Make it true and set the rc_buildnum(1,2,3,4) during Release Candidate Testing
    private Boolean isexperimentalVersion = false;

    private int rc_buildnum = 0;
    /**
     * The Build version.
     */
    public String buildVersion = (!isexperimentalVersion) ? "" : "RC_" + rc_buildnum;
    private View view;
    private AppDialogLoader loader;
    ;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.activity_about, container, false);

        loader = AppDialogLoader.getLoader(getActivity());
        Utils.updateActionBarForFeatures(getActivity(), new About().getClass().getName());
        initUi();

        return view;
    }

    private void initUi() {

        txtVersion = (TextView) view.findViewById(R.id.txtVersion);


        text = "    App Version: " + BuildConfig.VERSION_NAME + buildVersion + "" + "\n"
                + "MoBLE Lib Version: " + mobleNetwork.getlibversion();

        final Button Lic_Agree = (Button) view.findViewById(R.id.btnLicense);
        Lic_Agree.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                /*Intent test = new Intent(view.getContext(), LicenceAgreement.class);
                startActivity(test);*/
                Utils.moveToFragment(getActivity(), new LicenceAgreementFragment(), null, 0);
            }
        });

        txtVersion.setText(text);
    }

    /**
     * The type Url span no underline.
     */
    @SuppressLint("ParcelCreator")
    public class URLSpanNoUnderline extends URLSpan {

        /**
         * Instantiates a new Url span no underline.
         *
         * @param url the url
         */
        public URLSpanNoUnderline(String url) {
            super(url);
        }

        @Override
        public void updateDrawState(TextPaint ds) {
            super.updateDrawState(ds);
            ds.setUnderlineText(false);
        }
    }

    /**
     * Setbuild version string.
     *
     * @return the string
     */
    public String setbuildVersion() {

        return buildVersion;
    }

}
