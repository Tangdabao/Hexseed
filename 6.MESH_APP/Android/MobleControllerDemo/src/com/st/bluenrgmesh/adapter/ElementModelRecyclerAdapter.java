/**
 ******************************************************************************
 * @file    ElementModelRecylerAdapter.java
 * @author  BLE Mesh Team
 * @version V1.05.000
 * @date    10-April-2018
 * @brief   User Application file
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; COPYRIGHT(c) 2017 STMicroelectronics</center></h2>
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
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
 *
 * BlueNRG-Mesh is based on Motorola’s Mesh Over Bluetooth Low Energy (MoBLE)
 * technology. STMicroelectronics has done suitable updates in the firmware
 * and Android Mesh layers suitably.
 *
 ******************************************************************************
 */

package com.st.bluenrgmesh.adapter;

import android.content.Context;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.st.bluenrgmesh.R;
import com.st.bluenrgmesh.models.meshdata.Model;

import java.util.ArrayList;


public class ElementModelRecyclerAdapter extends RecyclerView.Adapter<ElementModelRecyclerAdapter.ViewHolder> {

    private final IRecyclerViewHolderClicks listener;
    private ArrayList<Model> models;
    Context context;

    public ElementModelRecyclerAdapter(Context context, ArrayList<Model> models, IRecyclerViewHolderClicks iRecyclerViewHolderClicks) {

        this.context = context;
        this.models = models;
        this.listener = iRecyclerViewHolderClicks;
    }

    public static interface IRecyclerViewHolderClicks {
        /**
         * On click recycler item.
         *
         * @param v           the v
         * @param isSelected the str selected
         */
        public void onClickRecyclerItem(View v, Model model, boolean isSelected,int position);
    }


    @Override
    public ElementModelRecyclerAdapter.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.element_model_row, parent, false);

        ElementModelRecyclerAdapter.ViewHolder vh = new ElementModelRecyclerAdapter.ViewHolder(v);

        return vh;
    }

    @Override
    public void onBindViewHolder(final ElementModelRecyclerAdapter.ViewHolder holder, final int position) {

        if(models.get(position).isChecked())
        {
            holder.cvModel.setCardBackgroundColor(context.getResources().getColor(R.color.lightgreen0));
        }
        else
        {
            holder.cvModel.setCardBackgroundColor(context.getResources().getColor(R.color.white));
        }
        holder.txtModelId.setText("Model Id : " + models.get(position).getModelId());
        holder.cvModel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                listener.onClickRecyclerItem(v, models.get(position), true, position);
            }
        });


    }

    @Override
    public int getItemCount() {
        return models.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        private final CardView cvModel;
        private TextView txtModelId;

        public ViewHolder(View itemView) {
            super(itemView);

            txtModelId = (TextView) itemView.findViewById(R.id.txtModelId);
            cvModel = (CardView) itemView.findViewById(R.id.cvModel);
        }
    }
}
