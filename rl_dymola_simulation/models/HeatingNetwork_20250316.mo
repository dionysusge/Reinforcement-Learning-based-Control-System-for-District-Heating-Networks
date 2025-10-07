within ;
package HeatingNetwork_20250316 "供热管网"

  model Pipe "管道"
    parameter Modelica.Units.SI.Length Length "管道长度";
    parameter Modelica.Units.SI.Diameter Diameter "管道直径";
    parameter Modelica.Units.SI.Length roughness=2.5e-5 "管道粗糙度";

    Modelica.Fluid.Pipes.DynamicPipe pipe(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      allowFlowReversal=true,
      length=Length,
      diameter=Diameter,
      roughness=roughness)
      annotation (Placement(transformation(extent={{-8,10},{12,30}})));
    Modelica.Fluid.Pipes.DynamicPipe pipe1(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      allowFlowReversal=true,                                                                            length=Length, diameter=Diameter,
      roughness=roughness)
      annotation (Placement(transformation(extent={{10,-30},{-10,-10}})));
    Modelica.Fluid.Interfaces.FluidPort_a port_a(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)                                                                   "供水入口"
      annotation (Placement(transformation(extent={{-110,10},{-90,30}})));
    Modelica.Fluid.Interfaces.FluidPort_b port_b(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)                                                                   "供水出口"
      annotation (Placement(transformation(extent={{90,10},{110,30}})));
    Modelica.Fluid.Interfaces.FluidPort_a port_a1(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)                                                                    "回水入口"
      annotation (Placement(transformation(extent={{90,-30},{110,-10}})));
    Modelica.Fluid.Interfaces.FluidPort_b port_b1(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)                                                                    "回水出口"
      annotation (Placement(transformation(extent={{-110,-30},{-90,-10}})));
  equation
    connect(port_a, pipe.port_a)
      annotation (Line(points={{-100,20},{-8,20}},  color={0,127,255}));
    connect(pipe.port_b, port_b)
      annotation (Line(points={{12,20},{100,20}}, color={0,127,255}));
    connect(port_b1, pipe1.port_b)
      annotation (Line(points={{-100,-20},{-10,-20}}, color={0,127,255}));
    connect(pipe1.port_a, port_a1)
      annotation (Line(points={{10,-20},{100,-20}}, color={0,127,255}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
          Rectangle(
            extent={{-100,40},{100,-48}},
            fillPattern=FillPattern.HorizontalCylinder,
            fillColor={0,127,255}), Text(
            extent={{-54,24},{64,-20}},
            textColor={0,0,0},
            textString="pipe",
            textStyle={TextStyle.Bold})}),                         Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end Pipe;

  model User "热用户"
    parameter Modelica.Units.SI.Length Length "管道长度";
    parameter Modelica.Units.SI.Diameter Diameter "管道直径";
  //   parameter Real sf=0.0214 "摩擦因子";
    parameter Modelica.Units.SI.MassFlowRate mflow_start=5 "用户初始流量";
  //   final parameter Modelica.Units.SI.Length roughness=10^(1/sf^0.5/(-2))*3.7 "管道粗糙度";
  //   final parameter Medium = Modelica.Media.Water.StandardWater;

    Modelica.Fluid.Pipes.DynamicPipe pipe(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      allowFlowReversal=true,
      length=Length,
      diameter=Diameter,
      m_flow_start=mflow_start,
      use_HeatTransfer=true)
      annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
    Modelica.Fluid.Interfaces.FluidPort_a port_a(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)                                                                   "供水入口"
      annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
    Modelica.Fluid.Interfaces.FluidPort_b port_b(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)                                                                   "供水出口"
      annotation (Placement(transformation(extent={{90,-10},{110,10}})));
    Modelica.Thermal.HeatTransfer.Sources.PrescribedHeatFlow prescribedHeatFlow
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={0,22})));
    Modelica.Blocks.Interfaces.RealInput Q "热负荷" annotation (Placement(
          transformation(
          extent={{-20,-20},{20,20}},
          rotation=-90,
          origin={0,60})));
  equation
    connect(port_a, pipe.port_a)
      annotation (Line(points={{-100,0},{-10,0}},   color={0,127,255}));
    connect(pipe.port_b, port_b)
      annotation (Line(points={{10,0},{100,0}},   color={0,127,255}));
    connect(prescribedHeatFlow.port, pipe.heatPorts[1]) annotation (Line(points={{
            -1.77636e-15,12},{-1.77636e-15,8.2},{0.1,8.2},{0.1,4.4}}, color={191,0,
            0}));
    connect(prescribedHeatFlow.Q_flow, Q) annotation (Line(points={{1.88738e-15,32},
            {1.88738e-15,43},{0,43},{0,60}}, color={0,0,127}));
    annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
          Rectangle(
            extent={{-100,40},{100,-48}},
            fillPattern=FillPattern.HorizontalCylinder,
            fillColor={0,127,255}), Text(
            extent={{-62,30},{66,-26}},
            textColor={0,0,0},
            textStyle={TextStyle.Bold},
            textString="user")}),                                  Diagram(
          coordinateSystem(preserveAspectRatio=false)));
  end User;

  model HeatingNetWork_Case01 "供热管网"
    Modelica.Fluid.Machines.ControlledPump pump(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      p_b_start=400000,
      m_flow_start=44,
      N_nominal(displayUnit="rpm"),
      T_start=313.15,
      p_a_nominal=300000,
      p_b_nominal=800000,
      m_flow_nominal=208.4,
      use_m_flow_set=true) "循环泵"
      annotation (Placement(transformation(extent={{-388,-42},{-368,-22}})));
    Pipe pipe(
      Length=8.39, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-248,-44},{-228,-24}})));
    Modelica.Fluid.Sources.Boundary_pT boundary(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      use_p_in=false,
      use_T_in=true,
      p=300000,
      T=323.15,
      nPorts=1) "供水边界"
      annotation (Placement(transformation(extent={{-436,-22},{-416,-42}})));
    Modelica.Fluid.Sources.Boundary_pT boundary1(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      use_p_in=false,
      use_T_in=false,
      p=200000,
      nPorts=3) annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=-90,
          origin={-328,-80})));
    Modelica.Fluid.Sensors.Pressure pressure(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-266,-20},{-246,0}})));
    Modelica.Blocks.Sources.RealExpression realExpression15(y=time/3600)
      annotation (Placement(transformation(extent={{-302,-8},{-322,12}})));
    Modelica.Blocks.Tables.CombiTable1Ds mflow(table=[0,178.54; 2,178.54; 4,
          178.54; 6,178.54; 8,178.54; 10,178.54; 12,178.54; 14,178.54; 16,
          178.54; 18,178.54; 20,178.54; 22,178.54; 24,178.54; 26,178.54; 28,
          178.54; 30,178.54; 32,178.54; 34,178.54; 36,178.54; 38,178.54; 40,
          178.54; 42,178.54; 44,178.54; 46,178.54; 48,178.54; 50,178.54; 52,
          178.54; 54,178.54; 56,178.54; 58,178.54; 60,178.54; 62,178.54; 64,
          178.54; 66,178.54; 68,178.54; 70,178.54; 72,178.54; 74,178.54; 76,
          178.54; 78,178.54; 80,178.54; 82,178.54; 84,178.54; 86,178.54; 88,
          178.54; 90,178.54; 92,178.54; 94,178.54; 96,178.54; 98,178.54; 100,
          178.54; 102,178.54; 104,178.54; 106,178.54; 108,178.54; 110,178.54;
          112,178.54; 114,178.54; 116,178.54; 118,178.54; 120,178.54; 122,
          178.54; 124,178.54; 126,178.54; 128,178.54; 130,178.54; 132,178.54;
          134,178.54; 136,178.54; 138,178.54; 140,178.54; 142,178.54; 144,
          178.54; 146,178.54; 148,178.54; 150,178.54; 152,178.54; 154,178.54;
          156,178.54; 158,178.54; 160,178.54; 162,178.54; 164,178.54; 166,
          178.54; 168,178.54; 170,178.54; 172,178.54; 174,178.54; 176,178.54;
          178,178.54; 180,178.54; 182,178.54; 184,178.54; 186,178.54; 188,
          178.54; 190,178.54])           "循环流量，kg/s"
      annotation (Placement(transformation(extent={{-332,-8},{-352,12}})));
    Modelica.Fluid.Sensors.Temperature temperature(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater) annotation (
        Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={-256,-70})));
    inner Modelica.Fluid.System system(
      p_ambient=300000,
      T_ambient=303.15,
      m_flow_start=4,
      use_eps_Re=true)
      annotation (Placement(transformation(extent={{334,110},{354,130}})));
    Modelica.Fluid.Sensors.Temperature temperature1(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater) annotation (
        Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=180,
          origin={-404,-12})));
    Modelica.Blocks.Sources.RealExpression realExpression13(y=time/3600)
      annotation (Placement(transformation(extent={{-502,-46},{-482,-26}})));
    Modelica.Blocks.Tables.CombiTable1Ds Tg(table=[0,310.41; 2,310.41; 4,310.56;
          6,310.7; 8,310.99; 10,311.21; 12,311.4; 14,311.39; 16,311.29; 18,
          311.4; 20,311.19; 22,311.12; 24,310.72; 26,310.38; 28,310.13; 30,
          309.55; 32,309.7; 34,309.36; 36,310.08; 38,309.17; 40,309.08; 42,
          309.04; 44,309; 46,309.18; 48,309.39; 50,309.17; 52,309.12; 54,309.12;
          56,309.06; 58,308.97; 60,309.57; 62,309.12; 64,308.83; 66,309.47; 68,
          309.74; 70,309.01; 72,308.82; 74,309.17; 76,309.21; 78,308.94; 80,
          309.19; 82,309.06; 84,309.05; 86,309.21; 88,309.36; 90,309.55; 92,
          309.17; 94,309.32; 96,309.08; 98,308.96; 100,309.14; 102,308.94; 104,
          309.02; 106,309.66; 108,309.39; 110,309.11; 112,309.2; 114,309.07;
          116,308.94; 118,309.19; 120,309.5; 122,308.9; 124,309.09; 126,309.16;
          128,309.9; 130,309.47; 132,310.06; 134,309.08; 136,309.47; 138,309.12;
          140,309.38; 142,308.8; 144,309.15; 146,309.27; 148,309.14; 150,309.17;
          152,309.26; 154,309.33; 156,309.15; 158,309.15; 160,308.93; 162,
          308.93; 164,309.08; 166,308.87; 168,309.04; 170,309.34; 172,309.06;
          174,309.04; 176,309.24; 178,309.06; 180,309.16; 182,309.17; 184,
          308.98; 186,309.25; 188,309.12; 190,309.16])  "供水温度"
      annotation (Placement(transformation(extent={{-468,-46},{-448,-26}})));
    Pipe pipe1(Length=72, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-192,-24},{-172,-4}})));
    Pipe pipe2(Length=72, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-190,-64},{-170,-44}})));
    Pipe pipe3(Length=78, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-152,16})));
    Pipe pipe4(Length=12, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-136,-22})));
    User F8(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=5.78) "8栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-62,-2})));
    Modelica.Blocks.Tables.CombiTable1Ds F8_load(table=[0,-134815.03; 2,-136264.66;
          4,-140130.32; 6,-142304.76; 8,-145928.82; 10,-145928.82; 12,-139647.11;
          14,-134573.43; 16,-133607.01; 18,-137472.68; 20,-133848.62; 22,-136023.05;
          24,-128774.93; 26,-125875.68; 28,-123701.25; 30,-117177.94; 32,-123459.64;
          34,-117177.94; 36,-128291.72; 38,-106064.16; 40,-111137.84; 42,-113070.67;
          44,-112345.86; 46,-116936.34; 48,-122010.02; 50,-116453.13; 52,-115486.71;
          54,-115969.92; 56,-115003.5; 58,-111862.65; 60,-126117.29; 62,-115003.5;
          64,-107996.99; 66,-119835.58; 68,-117902.75; 70,-106788.97; 72,-106305.76;
          74,-116211.52; 76,-117902.75; 78,-112104.26; 80,-119110.77; 82,-115245.11;
          84,-113795.48; 86,-117419.54; 88,-121768.42; 90,-122493.23; 92,-111137.84;
          94,-121526.81; 96,-116211.52; 98,-113795.48; 100,-118385.96; 102,-114761.9;
          104,-118144.36; 106,-133123.8; 108,-125150.87; 110,-117661.15; 112,-120560.4;
          114,-118385.96; 116,-114761.9; 118,-119110.77; 120,-128774.93; 122,-114278.69;
          124,-119352.38; 126,-122493.23; 128,-137955.88; 130,-124184.46; 132,-135056.64;
          134,-112829.07; 136,-127808.52; 138,-120077.19; 140,-124667.66; 142,-111137.84;
          144,-122010.02; 146,-125150.87; 148,-122251.62; 150,-123701.25; 152,-126358.89;
          154,-128533.33; 156,-122734.83; 158,-120802; 160,-115969.92; 162,-116936.34;
          164,-120560.4; 166,-116453.13; 168,-124184.46; 170,-128291.72; 172,-121768.42;
          174,-122251.62; 176,-128050.12; 178,-122734.83; 180,-123942.85; 182,-123701.25;
          184,-119352.38; 186,-124667.66; 188,-121043.6; 190,-121043.6])
      "#8负荷" annotation (Placement(transformation(extent={{-36,4},{-56,24}})));
    Modelica.Blocks.Sources.RealExpression realExpression8(y=time/3600)
      annotation (Placement(transformation(extent={{-8,4},{-28,24}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible4(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-60,-36})));

    Modelica.Blocks.Sources.Constant const4(k=1.000000)
      annotation (Placement(transformation(extent={{-36,-60},{-50,-46}})));
    User F5(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.125,
      mflow_start=10)   "5栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-204,48})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible1(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-208,70})));

    Modelica.Blocks.Tables.CombiTable1Ds F5_load1(table=[0,-233244; 2,-235752;
          4,-242440; 6,-246202; 8,-252472; 10,-252472; 12,-241604; 14,-232826;
          16,-231154; 18,-237842; 20,-231572; 22,-235334; 24,-222794; 26,-217778;
          28,-214016; 30,-202730; 32,-213598; 34,-202730; 36,-221958; 38,-183502;
          40,-192280; 42,-195624; 44,-194370; 46,-202312; 48,-211090; 50,-201476;
          52,-199804; 54,-200640; 56,-198968; 58,-193534; 60,-218196; 62,-198968;
          64,-186846; 66,-207328; 68,-203984; 70,-184756; 72,-183920; 74,-201058;
          76,-203984; 78,-193952; 80,-206074; 82,-199386; 84,-196878; 86,-203148;
          88,-210672; 90,-211926; 92,-192280; 94,-210254; 96,-201058; 98,-196878;
          100,-204820; 102,-198550; 104,-204402; 106,-230318; 108,-216524; 110,
          -203566; 112,-208582; 114,-204820; 116,-198550; 118,-206074; 120,-222794;
          122,-197714; 124,-206492; 126,-211926; 128,-238678; 130,-214852; 132,
          -233662; 134,-195206; 136,-221122; 138,-207746; 140,-215688; 142,-192280;
          144,-211090; 146,-216524; 148,-211508; 150,-214016; 152,-218614; 154,
          -222376; 156,-212344; 158,-209000; 160,-200640; 162,-202312; 164,-208582;
          166,-201476; 168,-214852; 170,-221958; 172,-210672; 174,-211508; 176,
          -221540; 178,-212344; 180,-214434; 182,-214016; 184,-206492; 186,-215688;
          188,-209418; 190,-209418])
      "#5负荷"
      annotation (Placement(transformation(extent={{-228,18},{-208,38}})));
    Modelica.Blocks.Sources.RealExpression realExpression1(y=time/3600)
      annotation (Placement(transformation(extent={{-256,18},{-236,38}})));
    Modelica.Blocks.Sources.Constant const1(k=0.749560)
      annotation (Placement(transformation(extent={{-232,80},{-218,94}})));
    Pipe pipe6(Length=6, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-102,-4})));
    Pipe pipe7(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-170,50})));
    Pipe pipe8(Length=8, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-152,72})));
    User F6(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.125,
      mflow_start=10)   "6栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-46,96})));
    Modelica.Blocks.Tables.CombiTable1Ds F6_load(table=[0,-233244; 1,-235752; 2,
          -242440; 3,-246202; 4,-252472; 5,-252472; 6,-241604; 7,-232826; 8,-231154;
          9,-237842; 10,-231572; 11,-235334; 12,-222794; 13,-217778; 14,-214016;
          15,-202730; 16,-213598; 17,-202730; 18,-221958; 19,-183502; 20,-192280;
          21,-195624; 22,-194370; 23,-202312; 24,-211090; 25,-201476; 26,-199804;
          27,-200640; 28,-198968; 29,-193534; 30,-218196; 31,-198968; 32,-186846;
          33,-207328; 34,-203984; 35,-184756; 36,-183920; 37,-201058; 38,-203984;
          39,-193952; 40,-206074; 41,-199386; 42,-196878; 43,-203148; 44,-210672;
          45,-211926; 46,-192280; 47,-210254; 48,-201058; 49,-196878; 50,-204820;
          51,-198550; 52,-204402; 53,-230318; 54,-216524; 55,-203566; 56,-208582;
          57,-204820; 58,-198550; 59,-206074; 60,-222794; 61,-197714; 62,-206492;
          63,-211926; 64,-238678; 65,-214852; 66,-233662; 67,-195206; 68,-221122;
          69,-207746; 70,-215688; 71,-192280; 72,-211090; 73,-216524; 74,-211508;
          75,-214016; 76,-218614; 77,-222376; 78,-212344; 79,-209000; 80,-200640;
          81,-202312; 82,-208582; 83,-201476; 84,-214852; 85,-221958; 86,-210672;
          87,-211508; 88,-221540; 89,-212344; 90,-214434; 91,-214016; 92,-206492;
          93,-215688; 94,-209418; 95,-209418])
      "#6负荷"
      annotation (Placement(transformation(extent={{-24,110},{-44,130}})));
    Modelica.Blocks.Sources.RealExpression realExpression4(y=time/3600)
      annotation (Placement(transformation(extent={{4,110},{-16,130}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible2(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-64,66})));

    Modelica.Blocks.Sources.Constant const2(k=0.619521)
      annotation (Placement(transformation(extent={{-46,40},{-60,54}})));
    Pipe pipe9(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-106,94})));
    Pipe pipe10(Length=8, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-152,120})));
    Pipe pipe11(Length=12, Diameter(displayUnit="mm") = 0.07)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-142,194})));
    Pipe pipe12(Length=12, Diameter(displayUnit="mm") = 0.07)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-60,194})));
    User F4_1(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=5.78) "4栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-164,244})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible3(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-166,268})));

    Modelica.Blocks.Tables.CombiTable1Ds F4_1_load(table=[0,-55278.83; 2,-55873.22;
          4,-57458.28; 6,-58349.87; 8,-59835.86; 10,-59835.86; 12,-57260.15; 14,
          -55179.76; 16,-54783.5; 18,-56368.55; 20,-54882.56; 22,-55774.16; 24,
          -52802.18; 26,-51613.39; 28,-50721.79; 30,-48047.01; 32,-50622.73; 34,
          -48047.01; 36,-52604.05; 38,-43489.97; 40,-45570.36; 42,-46362.89; 44,
          -46065.69; 46,-47947.94; 48,-50028.33; 50,-47749.81; 52,-47353.55; 54,
          -47551.68; 56,-47155.42; 58,-45867.56; 60,-51712.45; 62,-47155.42; 64,
          -44282.5; 66,-49136.74; 68,-48344.21; 70,-43787.17; 72,-43589.04; 74,
          -47650.75; 76,-48344.21; 78,-45966.62; 80,-48839.54; 82,-47254.48; 84,
          -46660.09; 86,-48146.08; 88,-49929.26; 90,-50226.46; 92,-45570.36; 94,
          -49830.2; 96,-47650.75; 98,-46660.09; 100,-48542.34; 102,-47056.35;
          104,-48443.27; 106,-54585.37; 108,-51316.19; 110,-48245.14; 112,-49433.93;
          114,-48542.34; 116,-47056.35; 118,-48839.54; 120,-52802.18; 122,-46858.22;
          124,-48938.6; 126,-50226.46; 128,-56566.69; 130,-50919.92; 132,-55377.89;
          134,-46263.82; 136,-52405.91; 138,-49235.8; 140,-51118.06; 142,-45570.36;
          144,-50028.33; 146,-51316.19; 148,-50127.4; 150,-50721.79; 152,-51811.52;
          154,-52703.11; 156,-50325.53; 158,-49533; 160,-47551.68; 162,-47947.94;
          164,-49433.93; 166,-47749.81; 168,-50919.92; 170,-52604.05; 172,-49929.26;
          174,-50127.4; 176,-52504.98; 178,-50325.53; 180,-50820.86; 182,-50721.79;
          184,-48938.6; 186,-51118.06; 188,-49632.07; 190,-49632.07])
      "#4-1负荷"
      annotation (Placement(transformation(extent={{-210,218},{-190,238}})));
    Modelica.Blocks.Sources.RealExpression realExpression5(y=time/3600)
      annotation (Placement(transformation(extent={{-190,196},{-210,216}})));
    Modelica.Blocks.Sources.Constant const3(k=0.973089)
      annotation (Placement(transformation(extent={{-194,278},{-180,292}})));
    User F4_2(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.07,
      mflow_start=2.37) "4栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-76,252})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible5(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-78,276})));

    Modelica.Blocks.Tables.CombiTable1Ds F4_1_load1(table=[0,-134815.03; 2,-136264.66;
          4,-140130.32; 6,-142304.76; 8,-145928.82; 10,-145928.82; 12,-139647.11;
          14,-134573.43; 16,-133607.01; 18,-137472.68; 20,-133848.62; 22,-136023.05;
          24,-128774.93; 26,-125875.68; 28,-123701.25; 30,-117177.94; 32,-123459.64;
          34,-117177.94; 36,-128291.72; 38,-106064.16; 40,-111137.84; 42,-113070.67;
          44,-112345.86; 46,-116936.34; 48,-122010.02; 50,-116453.13; 52,-115486.71;
          54,-115969.92; 56,-115003.5; 58,-111862.65; 60,-126117.29; 62,-115003.5;
          64,-107996.99; 66,-119835.58; 68,-117902.75; 70,-106788.97; 72,-106305.76;
          74,-116211.52; 76,-117902.75; 78,-112104.26; 80,-119110.77; 82,-115245.11;
          84,-113795.48; 86,-117419.54; 88,-121768.42; 90,-122493.23; 92,-111137.84;
          94,-121526.81; 96,-116211.52; 98,-113795.48; 100,-118385.96; 102,-114761.9;
          104,-118144.36; 106,-133123.8; 108,-125150.87; 110,-117661.15; 112,-120560.4;
          114,-118385.96; 116,-114761.9; 118,-119110.77; 120,-128774.93; 122,-114278.69;
          124,-119352.38; 126,-122493.23; 128,-137955.88; 130,-124184.46; 132,-135056.64;
          134,-112829.07; 136,-127808.52; 138,-120077.19; 140,-124667.66; 142,-111137.84;
          144,-122010.02; 146,-125150.87; 148,-122251.62; 150,-123701.25; 152,-126358.89;
          154,-128533.33; 156,-122734.83; 158,-120802; 160,-115969.92; 162,-116936.34;
          164,-120560.4; 166,-116453.13; 168,-124184.46; 170,-128291.72; 172,-121768.42;
          174,-122251.62; 176,-128050.12; 178,-122734.83; 180,-123942.85; 182,-123701.25;
          184,-119352.38; 186,-124667.66; 188,-121043.6; 190,-121043.6])
      "#4-1负荷"
      annotation (Placement(transformation(extent={{-102,222},{-82,242}})));
    Modelica.Blocks.Sources.RealExpression realExpression6(y=time/3600)
      annotation (Placement(transformation(extent={{-80,200},{-100,220}})));
    Modelica.Blocks.Sources.Constant const5(k=0.803945)
      annotation (Placement(transformation(extent={{-94,290},{-80,304}})));
    Pipe pipe13(Length=78, Diameter(displayUnit="mm") = 0.2)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-26,176})));
    Pipe pipe14(Length=12, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={36,198})));
    Pipe pipe15(Length=12, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={114,198})));
    User F3_1(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.07,
      mflow_start=2.37) "3栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={14,248})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible6(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={12,272})));

    Modelica.Blocks.Tables.CombiTable1Ds F3_1_load(table=[0,-55278.83; 2,-55873.22;
          4,-57458.28; 6,-58349.87; 8,-59835.86; 10,-59835.86; 12,-57260.15; 14,
          -55179.76; 16,-54783.5; 18,-56368.55; 20,-54882.56; 22,-55774.16; 24,
          -52802.18; 26,-51613.39; 28,-50721.79; 30,-48047.01; 32,-50622.73; 34,
          -48047.01; 36,-52604.05; 38,-43489.97; 40,-45570.36; 42,-46362.89; 44,
          -46065.69; 46,-47947.94; 48,-50028.33; 50,-47749.81; 52,-47353.55; 54,
          -47551.68; 56,-47155.42; 58,-45867.56; 60,-51712.45; 62,-47155.42; 64,
          -44282.5; 66,-49136.74; 68,-48344.21; 70,-43787.17; 72,-43589.04; 74,
          -47650.75; 76,-48344.21; 78,-45966.62; 80,-48839.54; 82,-47254.48; 84,
          -46660.09; 86,-48146.08; 88,-49929.26; 90,-50226.46; 92,-45570.36; 94,
          -49830.2; 96,-47650.75; 98,-46660.09; 100,-48542.34; 102,-47056.35;
          104,-48443.27; 106,-54585.37; 108,-51316.19; 110,-48245.14; 112,-49433.93;
          114,-48542.34; 116,-47056.35; 118,-48839.54; 120,-52802.18; 122,-46858.22;
          124,-48938.6; 126,-50226.46; 128,-56566.69; 130,-50919.92; 132,-55377.89;
          134,-46263.82; 136,-52405.91; 138,-49235.8; 140,-51118.06; 142,-45570.36;
          144,-50028.33; 146,-51316.19; 148,-50127.4; 150,-50721.79; 152,-51811.52;
          154,-52703.11; 156,-50325.53; 158,-49533; 160,-47551.68; 162,-47947.94;
          164,-49433.93; 166,-47749.81; 168,-50919.92; 170,-52604.05; 172,-49929.26;
          174,-50127.4; 176,-52504.98; 178,-50325.53; 180,-50820.86; 182,-50721.79;
          184,-48938.6; 186,-51118.06; 188,-49632.07; 190,-49632.07])
                                                             "#3-1负荷"
      annotation (Placement(transformation(extent={{-10,218},{10,238}})));
    Modelica.Blocks.Sources.RealExpression realExpression7(y=time/3600)
      annotation (Placement(transformation(extent={{10,196},{-10,216}})));
    Modelica.Blocks.Sources.Constant const6(k=0.923102)
      annotation (Placement(transformation(extent={{-16,282},{-2,296}})));
    User F3_2(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=5.78) "3栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={98,256})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible7(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={96,280})));

    Modelica.Blocks.Tables.CombiTable1Ds F3_2_load(table=[0,-134815.03; 2,-136264.66;
          4,-140130.32; 6,-142304.76; 8,-145928.82; 10,-145928.82; 12,-139647.11;
          14,-134573.43; 16,-133607.01; 18,-137472.68; 20,-133848.62; 22,-136023.05;
          24,-128774.93; 26,-125875.68; 28,-123701.25; 30,-117177.94; 32,-123459.64;
          34,-117177.94; 36,-128291.72; 38,-106064.16; 40,-111137.84; 42,-113070.67;
          44,-112345.86; 46,-116936.34; 48,-122010.02; 50,-116453.13; 52,-115486.71;
          54,-115969.92; 56,-115003.5; 58,-111862.65; 60,-126117.29; 62,-115003.5;
          64,-107996.99; 66,-119835.58; 68,-117902.75; 70,-106788.97; 72,-106305.76;
          74,-116211.52; 76,-117902.75; 78,-112104.26; 80,-119110.77; 82,-115245.11;
          84,-113795.48; 86,-117419.54; 88,-121768.42; 90,-122493.23; 92,-111137.84;
          94,-121526.81; 96,-116211.52; 98,-113795.48; 100,-118385.96; 102,-114761.9;
          104,-118144.36; 106,-133123.8; 108,-125150.87; 110,-117661.15; 112,-120560.4;
          114,-118385.96; 116,-114761.9; 118,-119110.77; 120,-128774.93; 122,-114278.69;
          124,-119352.38; 126,-122493.23; 128,-137955.88; 130,-124184.46; 132,-135056.64;
          134,-112829.07; 136,-127808.52; 138,-120077.19; 140,-124667.66; 142,-111137.84;
          144,-122010.02; 146,-125150.87; 148,-122251.62; 150,-123701.25; 152,-126358.89;
          154,-128533.33; 156,-122734.83; 158,-120802; 160,-115969.92; 162,-116936.34;
          164,-120560.4; 166,-116453.13; 168,-124184.46; 170,-128291.72; 172,-121768.42;
          174,-122251.62; 176,-128050.12; 178,-122734.83; 180,-123942.85; 182,-123701.25;
          184,-119352.38; 186,-124667.66; 188,-121043.6; 190,-121043.6])
      "#3_2负荷"
      annotation (Placement(transformation(extent={{72,226},{92,246}})));
    Modelica.Blocks.Sources.RealExpression realExpression9(y=time/3600)
      annotation (Placement(transformation(extent={{94,204},{74,224}})));
    Modelica.Blocks.Sources.Constant const7(k=0.799988)
      annotation (Placement(transformation(extent={{76,290},{90,304}})));
    Pipe pipe16(Length=78, Diameter(displayUnit="mm") = 0.2)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={138,176})));

    Pipe pipe18(Length=72, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={270,176})));
    Pipe pipe19(Length=12, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={342,196})));
    User F1(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=5.78) "1栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={326,254})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible9(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={324,278})));

    Modelica.Blocks.Tables.CombiTable1Ds F1oad(table=[0,-134815.03; 2,-136264.66;
          4,-140130.32; 6,-142304.76; 8,-145928.82; 10,-145928.82; 12,-139647.11;
          14,-134573.43; 16,-133607.01; 18,-137472.68; 20,-133848.62; 22,-136023.05;
          24,-128774.93; 26,-125875.68; 28,-123701.25; 30,-117177.94; 32,-123459.64;
          34,-117177.94; 36,-128291.72; 38,-106064.16; 40,-111137.84; 42,-113070.67;
          44,-112345.86; 46,-116936.34; 48,-122010.02; 50,-116453.13; 52,-115486.71;
          54,-115969.92; 56,-115003.5; 58,-111862.65; 60,-126117.29; 62,-115003.5;
          64,-107996.99; 66,-119835.58; 68,-117902.75; 70,-106788.97; 72,-106305.76;
          74,-116211.52; 76,-117902.75; 78,-112104.26; 80,-119110.77; 82,-115245.11;
          84,-113795.48; 86,-117419.54; 88,-121768.42; 90,-122493.23; 92,-111137.84;
          94,-121526.81; 96,-116211.52; 98,-113795.48; 100,-118385.96; 102,-114761.9;
          104,-118144.36; 106,-133123.8; 108,-125150.87; 110,-117661.15; 112,-120560.4;
          114,-118385.96; 116,-114761.9; 118,-119110.77; 120,-128774.93; 122,-114278.69;
          124,-119352.38; 126,-122493.23; 128,-137955.88; 130,-124184.46; 132,-135056.64;
          134,-112829.07; 136,-127808.52; 138,-120077.19; 140,-124667.66; 142,-111137.84;
          144,-122010.02; 146,-125150.87; 148,-122251.62; 150,-123701.25; 152,-126358.89;
          154,-128533.33; 156,-122734.83; 158,-120802; 160,-115969.92; 162,-116936.34;
          164,-120560.4; 166,-116453.13; 168,-124184.46; 170,-128291.72; 172,-121768.42;
          174,-122251.62; 176,-128050.12; 178,-122734.83; 180,-123942.85; 182,-123701.25;
          184,-119352.38; 186,-124667.66; 188,-121043.6; 190,-121043.6])
                                             "#1负荷"
      annotation (Placement(transformation(extent={{300,226},{320,246}})));
    Modelica.Blocks.Sources.RealExpression realExpression2(y=time/3600)
      annotation (Placement(transformation(extent={{322,202},{302,222}})));
    Modelica.Blocks.Sources.Constant const9(k=0.500000)
      annotation (Placement(transformation(extent={{296,288},{310,302}})));
    Pipe pipe20(Length=8, Diameter(displayUnit="mm") = 0.2)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={156,148})));
    User F7(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.125,
      mflow_start=10)   "7栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={230,124})));
    Modelica.Blocks.Tables.CombiTable1Ds F7_load(table=[0,-233244; 2,-235752; 4,
          -242440; 6,-246202; 8,-252472; 10,-252472; 12,-241604; 14,-232826; 16,
          -231154; 18,-237842; 20,-231572; 22,-235334; 24,-222794; 26,-217778;
          28,-214016; 30,-202730; 32,-213598; 34,-202730; 36,-221958; 38,-183502;
          40,-192280; 42,-195624; 44,-194370; 46,-202312; 48,-211090; 50,-201476;
          52,-199804; 54,-200640; 56,-198968; 58,-193534; 60,-218196; 62,-198968;
          64,-186846; 66,-207328; 68,-203984; 70,-184756; 72,-183920; 74,-201058;
          76,-203984; 78,-193952; 80,-206074; 82,-199386; 84,-196878; 86,-203148;
          88,-210672; 90,-211926; 92,-192280; 94,-210254; 96,-201058; 98,-196878;
          100,-204820; 102,-198550; 104,-204402; 106,-230318; 108,-216524; 110,
          -203566; 112,-208582; 114,-204820; 116,-198550; 118,-206074; 120,-222794;
          122,-197714; 124,-206492; 126,-211926; 128,-238678; 130,-214852; 132,
          -233662; 134,-195206; 136,-221122; 138,-207746; 140,-215688; 142,-192280;
          144,-211090; 146,-216524; 148,-211508; 150,-214016; 152,-218614; 154,
          -222376; 156,-212344; 158,-209000; 160,-200640; 162,-202312; 164,-208582;
          166,-201476; 168,-214852; 170,-221958; 172,-210672; 174,-211508; 176,
          -221540; 178,-212344; 180,-214434; 182,-214016; 184,-206492; 186,-215688;
          188,-209418; 190,-209418])
      "#7负荷"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=180,
          origin={212,146})));
    Modelica.Blocks.Sources.RealExpression realExpression11(y=time/3600)
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=180,
          origin={180,146})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible10(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={232,94})));

    Modelica.Blocks.Sources.Constant const10(k=0.595922)
      annotation (Placement(transformation(extent={{212,70},{226,84}})));
    Pipe pipe21(Length=36, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={190,122})));
    Pipe pipe22(Length=90, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={156,82})));
    Pipe pipe23(Length=36, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={192,50})));
    Pipe pipe24(Length=36, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={260,50})));
    Pipe pipe25(Length=12, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,10},{10,-10}},
          rotation=-90,
          origin={222,24})));
    User F9_2(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=5.78) "9栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={310,52})));
    Modelica.Blocks.Tables.CombiTable1Ds F9_2_load(table=[0,-134815.03; 2,-136264.66;
          4,-140130.32; 6,-142304.76; 8,-145928.82; 10,-145928.82; 12,-139647.11;
          14,-134573.43; 16,-133607.01; 18,-137472.68; 20,-133848.62; 22,-136023.05;
          24,-128774.93; 26,-125875.68; 28,-123701.25; 30,-117177.94; 32,-123459.64;
          34,-117177.94; 36,-128291.72; 38,-106064.16; 40,-111137.84; 42,-113070.67;
          44,-112345.86; 46,-116936.34; 48,-122010.02; 50,-116453.13; 52,-115486.71;
          54,-115969.92; 56,-115003.5; 58,-111862.65; 60,-126117.29; 62,-115003.5;
          64,-107996.99; 66,-119835.58; 68,-117902.75; 70,-106788.97; 72,-106305.76;
          74,-116211.52; 76,-117902.75; 78,-112104.26; 80,-119110.77; 82,-115245.11;
          84,-113795.48; 86,-117419.54; 88,-121768.42; 90,-122493.23; 92,-111137.84;
          94,-121526.81; 96,-116211.52; 98,-113795.48; 100,-118385.96; 102,-114761.9;
          104,-118144.36; 106,-133123.8; 108,-125150.87; 110,-117661.15; 112,-120560.4;
          114,-118385.96; 116,-114761.9; 118,-119110.77; 120,-128774.93; 122,-114278.69;
          124,-119352.38; 126,-122493.23; 128,-137955.88; 130,-124184.46; 132,-135056.64;
          134,-112829.07; 136,-127808.52; 138,-120077.19; 140,-124667.66; 142,-111137.84;
          144,-122010.02; 146,-125150.87; 148,-122251.62; 150,-123701.25; 152,-126358.89;
          154,-128533.33; 156,-122734.83; 158,-120802; 160,-115969.92; 162,-116936.34;
          164,-120560.4; 166,-116453.13; 168,-124184.46; 170,-128291.72; 172,-121768.42;
          174,-122251.62; 176,-128050.12; 178,-122734.83; 180,-123942.85; 182,-123701.25;
          184,-119352.38; 186,-124667.66; 188,-121043.6; 190,-121043.6])
      "#9负荷"
      annotation (Placement(transformation(extent={{336,58},{316,78}})));
    Modelica.Blocks.Sources.RealExpression realExpression12(y=time/3600)
      annotation (Placement(transformation(extent={{352,58},{332,78}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible12(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={300,26})));

    Modelica.Blocks.Sources.Constant const12(k=0.980507)
      annotation (Placement(transformation(extent={{282,2},{296,16}})));
    User F9_1(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=5.78) "9栋" annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=0,
          origin={180,4})));
    Modelica.Blocks.Tables.CombiTable1Ds F9_1_load(table=[0,-134815.03; 2,-136264.66;
          4,-140130.32; 6,-142304.76; 8,-145928.82; 10,-145928.82; 12,-139647.11;
          14,-134573.43; 16,-133607.01; 18,-137472.68; 20,-133848.62; 22,-136023.05;
          24,-128774.93; 26,-125875.68; 28,-123701.25; 30,-117177.94; 32,-123459.64;
          34,-117177.94; 36,-128291.72; 38,-106064.16; 40,-111137.84; 42,-113070.67;
          44,-112345.86; 46,-116936.34; 48,-122010.02; 50,-116453.13; 52,-115486.71;
          54,-115969.92; 56,-115003.5; 58,-111862.65; 60,-126117.29; 62,-115003.5;
          64,-107996.99; 66,-119835.58; 68,-117902.75; 70,-106788.97; 72,-106305.76;
          74,-116211.52; 76,-117902.75; 78,-112104.26; 80,-119110.77; 82,-115245.11;
          84,-113795.48; 86,-117419.54; 88,-121768.42; 90,-122493.23; 92,-111137.84;
          94,-121526.81; 96,-116211.52; 98,-113795.48; 100,-118385.96; 102,-114761.9;
          104,-118144.36; 106,-133123.8; 108,-125150.87; 110,-117661.15; 112,-120560.4;
          114,-118385.96; 116,-114761.9; 118,-119110.77; 120,-128774.93; 122,-114278.69;
          124,-119352.38; 126,-122493.23; 128,-137955.88; 130,-124184.46; 132,-135056.64;
          134,-112829.07; 136,-127808.52; 138,-120077.19; 140,-124667.66; 142,-111137.84;
          144,-122010.02; 146,-125150.87; 148,-122251.62; 150,-123701.25; 152,-126358.89;
          154,-128533.33; 156,-122734.83; 158,-120802; 160,-115969.92; 162,-116936.34;
          164,-120560.4; 166,-116453.13; 168,-124184.46; 170,-128291.72; 172,-121768.42;
          174,-122251.62; 176,-128050.12; 178,-122734.83; 180,-123942.85; 182,-123701.25;
          184,-119352.38; 186,-124667.66; 188,-121043.6; 190,-121043.6])
      "#9负荷"
      annotation (Placement(transformation(extent={{152,16},{172,36}})));
    Modelica.Blocks.Sources.RealExpression realExpression16(y=time/3600)
      annotation (Placement(transformation(extent={{112,16},{132,36}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible13(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=0,
          origin={198,-22})));

    Modelica.Blocks.Sources.Constant const13(k=0.988868)
      annotation (Placement(transformation(extent={{180,-46},{194,-32}})));

    Pipe pipe30(Length=20, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-88})));
    User F10(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.125,
      mflow_start=10)   "10栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-58,-108})));
    Modelica.Blocks.Tables.CombiTable1Ds F10_load(table=[0,-233244; 2,-235752;
          4,-242440; 6,-246202; 8,-252472; 10,-252472; 12,-241604; 14,-232826;
          16,-231154; 18,-237842; 20,-231572; 22,-235334; 24,-222794; 26,-217778;
          28,-214016; 30,-202730; 32,-213598; 34,-202730; 36,-221958; 38,-183502;
          40,-192280; 42,-195624; 44,-194370; 46,-202312; 48,-211090; 50,-201476;
          52,-199804; 54,-200640; 56,-198968; 58,-193534; 60,-218196; 62,-198968;
          64,-186846; 66,-207328; 68,-203984; 70,-184756; 72,-183920; 74,-201058;
          76,-203984; 78,-193952; 80,-206074; 82,-199386; 84,-196878; 86,-203148;
          88,-210672; 90,-211926; 92,-192280; 94,-210254; 96,-201058; 98,-196878;
          100,-204820; 102,-198550; 104,-204402; 106,-230318; 108,-216524; 110,
          -203566; 112,-208582; 114,-204820; 116,-198550; 118,-206074; 120,-222794;
          122,-197714; 124,-206492; 126,-211926; 128,-238678; 130,-214852; 132,
          -233662; 134,-195206; 136,-221122; 138,-207746; 140,-215688; 142,-192280;
          144,-211090; 146,-216524; 148,-211508; 150,-214016; 152,-218614; 154,
          -222376; 156,-212344; 158,-209000; 160,-200640; 162,-202312; 164,-208582;
          166,-201476; 168,-214852; 170,-221958; 172,-210672; 174,-211508; 176,
          -221540; 178,-212344; 180,-214434; 182,-214016; 184,-206492; 186,-215688;
          188,-209418; 190,-209418])
      "#10负荷"
      annotation (Placement(transformation(extent={{-32,-102},{-52,-82}})));
    Modelica.Blocks.Sources.RealExpression realExpression20(y=time/3600)
      annotation (Placement(transformation(extent={{-4,-102},{-24,-82}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible17(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-56,-138})));

    Modelica.Blocks.Sources.Constant const17(k=0.635664)
      annotation (Placement(transformation(extent={{-76,-164},{-62,-150}})));
    Pipe pipe31(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-98,-110})));
    Pipe pipe32(Length=20, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-150})));
    Pipe pipe33(Length=48, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-44,-184})));
    User F13(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=5.78) "13栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={158,-182})));
    Modelica.Blocks.Tables.CombiTable1Ds F13_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#13负荷"
      annotation (Placement(transformation(extent={{184,-176},{164,-156}})));
    Modelica.Blocks.Sources.RealExpression realExpression21(y=time/3600)
      annotation (Placement(transformation(extent={{218,-176},{198,-156}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible18(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={160,-212})));

    Modelica.Blocks.Sources.Constant const18(k=0.948706)
      annotation (Placement(transformation(extent={{140,-238},{154,-224}})));
    Pipe pipe34(Length=20, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-212})));
    Pipe pipe35(Length=6, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-94,-232})));
    User F12(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=5.78) "12栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-48,-230})));
    Modelica.Blocks.Tables.CombiTable1Ds F12_load(table=[0,-134815.03; 2,-136264.66;
          4,-140130.32; 6,-142304.76; 8,-145928.82; 10,-145928.82; 12,-139647.11;
          14,-134573.43; 16,-133607.01; 18,-137472.68; 20,-133848.62; 22,-136023.05;
          24,-128774.93; 26,-125875.68; 28,-123701.25; 30,-117177.94; 32,-123459.64;
          34,-117177.94; 36,-128291.72; 38,-106064.16; 40,-111137.84; 42,-113070.67;
          44,-112345.86; 46,-116936.34; 48,-122010.02; 50,-116453.13; 52,-115486.71;
          54,-115969.92; 56,-115003.5; 58,-111862.65; 60,-126117.29; 62,-115003.5;
          64,-107996.99; 66,-119835.58; 68,-117902.75; 70,-106788.97; 72,-106305.76;
          74,-116211.52; 76,-117902.75; 78,-112104.26; 80,-119110.77; 82,-115245.11;
          84,-113795.48; 86,-117419.54; 88,-121768.42; 90,-122493.23; 92,-111137.84;
          94,-121526.81; 96,-116211.52; 98,-113795.48; 100,-118385.96; 102,-114761.9;
          104,-118144.36; 106,-133123.8; 108,-125150.87; 110,-117661.15; 112,-120560.4;
          114,-118385.96; 116,-114761.9; 118,-119110.77; 120,-128774.93; 122,-114278.69;
          124,-119352.38; 126,-122493.23; 128,-137955.88; 130,-124184.46; 132,-135056.64;
          134,-112829.07; 136,-127808.52; 138,-120077.19; 140,-124667.66; 142,-111137.84;
          144,-122010.02; 146,-125150.87; 148,-122251.62; 150,-123701.25; 152,-126358.89;
          154,-128533.33; 156,-122734.83; 158,-120802; 160,-115969.92; 162,-116936.34;
          164,-120560.4; 166,-116453.13; 168,-124184.46; 170,-128291.72; 172,-121768.42;
          174,-122251.62; 176,-128050.12; 178,-122734.83; 180,-123942.85; 182,-123701.25;
          184,-119352.38; 186,-124667.66; 188,-121043.6; 190,-121043.6])
      "#12负荷"
      annotation (Placement(transformation(extent={{-24,-224},{-44,-204}})));
    Modelica.Blocks.Sources.RealExpression realExpression22(y=time/3600)
      annotation (Placement(transformation(extent={{6,-224},{-14,-204}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible19(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-50,-262})));

    Modelica.Blocks.Sources.Constant const19(k=0.537505)
      annotation (Placement(transformation(extent={{-70,-288},{-56,-274}})));
    Pipe pipe36(Length=120, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-286})));
    Pipe pipe37(Length=12, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-184,-236})));
    User F11(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.125,
      mflow_start=10)   "11栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-228,-258})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible20(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-230,-234})));

    Modelica.Blocks.Sources.Constant const20(k=0.500000)
      annotation (Placement(transformation(extent={{-254,-222},{-240,-208}})));
    Modelica.Blocks.Tables.CombiTable1Ds F11_load(table=[0,-233244; 2,-235752;
          4,-242440; 6,-246202; 8,-252472; 10,-252472; 12,-241604; 14,-232826;
          16,-231154; 18,-237842; 20,-231572; 22,-235334; 24,-222794; 26,-217778;
          28,-214016; 30,-202730; 32,-213598; 34,-202730; 36,-221958; 38,-183502;
          40,-192280; 42,-195624; 44,-194370; 46,-202312; 48,-211090; 50,-201476;
          52,-199804; 54,-200640; 56,-198968; 58,-193534; 60,-218196; 62,-198968;
          64,-186846; 66,-207328; 68,-203984; 70,-184756; 72,-183920; 74,-201058;
          76,-203984; 78,-193952; 80,-206074; 82,-199386; 84,-196878; 86,-203148;
          88,-210672; 90,-211926; 92,-192280; 94,-210254; 96,-201058; 98,-196878;
          100,-204820; 102,-198550; 104,-204402; 106,-230318; 108,-216524; 110,
          -203566; 112,-208582; 114,-204820; 116,-198550; 118,-206074; 120,-222794;
          122,-197714; 124,-206492; 126,-211926; 128,-238678; 130,-214852; 132,
          -233662; 134,-195206; 136,-221122; 138,-207746; 140,-215688; 142,-192280;
          144,-211090; 146,-216524; 148,-211508; 150,-214016; 152,-218614; 154,
          -222376; 156,-212344; 158,-209000; 160,-200640; 162,-202312; 164,-208582;
          166,-201476; 168,-214852; 170,-221958; 172,-210672; 174,-211508; 176,
          -221540; 178,-212344; 180,-214434; 182,-214016; 184,-206492; 186,-215688;
          188,-209418; 190,-209418])
      "#11负荷"
      annotation (Placement(transformation(extent={{-254,-290},{-234,-270}})));
    Modelica.Blocks.Sources.RealExpression realExpression23(y=time/3600)
      annotation (Placement(transformation(extent={{-282,-290},{-262,-270}})));
    Pipe pipe38(Length=12, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-180,-322})));
    User F18(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.125,
      mflow_start=10)   "18栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-244,-346})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible21(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-242,-320})));

    Modelica.Blocks.Sources.Constant const21(k=1.000000)
      annotation (Placement(transformation(extent={{-272,-310},{-258,-296}})));
    Modelica.Blocks.Tables.CombiTable1Ds F18_load(table=[0,-233244; 2,-235752;
          4,-242440; 6,-246202; 8,-252472; 10,-252472; 12,-241604; 14,-232826;
          16,-231154; 18,-237842; 20,-231572; 22,-235334; 24,-222794; 26,-217778;
          28,-214016; 30,-202730; 32,-213598; 34,-202730; 36,-221958; 38,-183502;
          40,-192280; 42,-195624; 44,-194370; 46,-202312; 48,-211090; 50,-201476;
          52,-199804; 54,-200640; 56,-198968; 58,-193534; 60,-218196; 62,-198968;
          64,-186846; 66,-207328; 68,-203984; 70,-184756; 72,-183920; 74,-201058;
          76,-203984; 78,-193952; 80,-206074; 82,-199386; 84,-196878; 86,-203148;
          88,-210672; 90,-211926; 92,-192280; 94,-210254; 96,-201058; 98,-196878;
          100,-204820; 102,-198550; 104,-204402; 106,-230318; 108,-216524; 110,
          -203566; 112,-208582; 114,-204820; 116,-198550; 118,-206074; 120,-222794;
          122,-197714; 124,-206492; 126,-211926; 128,-238678; 130,-214852; 132,
          -233662; 134,-195206; 136,-221122; 138,-207746; 140,-215688; 142,-192280;
          144,-211090; 146,-216524; 148,-211508; 150,-214016; 152,-218614; 154,
          -222376; 156,-212344; 158,-209000; 160,-200640; 162,-202312; 164,-208582;
          166,-201476; 168,-214852; 170,-221958; 172,-210672; 174,-211508; 176,
          -221540; 178,-212344; 180,-214434; 182,-214016; 184,-206492; 186,-215688;
          188,-209418; 190,-209418])
      "#18负荷"
      annotation (Placement(transformation(extent={{-274,-380},{-254,-360}})));
    Modelica.Blocks.Sources.RealExpression realExpression24(y=time/3600)
      annotation (Placement(transformation(extent={{-250,-400},{-270,-380}})));
    Pipe pipe39(Length=60, Diameter(displayUnit="mm") = 0.2)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-348})));
    Pipe pipe40(Length=150, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={22,-374})));
    User F12_2(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=5.78) "12栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={66,-294})));
    Modelica.Blocks.Tables.CombiTable1Ds F12_2_load(table=[0,-134815.03; 2,-136264.66;
          4,-140130.32; 6,-142304.76; 8,-145928.82; 10,-145928.82; 12,-139647.11;
          14,-134573.43; 16,-133607.01; 18,-137472.68; 20,-133848.62; 22,-136023.05;
          24,-128774.93; 26,-125875.68; 28,-123701.25; 30,-117177.94; 32,-123459.64;
          34,-117177.94; 36,-128291.72; 38,-106064.16; 40,-111137.84; 42,-113070.67;
          44,-112345.86; 46,-116936.34; 48,-122010.02; 50,-116453.13; 52,-115486.71;
          54,-115969.92; 56,-115003.5; 58,-111862.65; 60,-126117.29; 62,-115003.5;
          64,-107996.99; 66,-119835.58; 68,-117902.75; 70,-106788.97; 72,-106305.76;
          74,-116211.52; 76,-117902.75; 78,-112104.26; 80,-119110.77; 82,-115245.11;
          84,-113795.48; 86,-117419.54; 88,-121768.42; 90,-122493.23; 92,-111137.84;
          94,-121526.81; 96,-116211.52; 98,-113795.48; 100,-118385.96; 102,-114761.9;
          104,-118144.36; 106,-133123.8; 108,-125150.87; 110,-117661.15; 112,-120560.4;
          114,-118385.96; 116,-114761.9; 118,-119110.77; 120,-128774.93; 122,-114278.69;
          124,-119352.38; 126,-122493.23; 128,-137955.88; 130,-124184.46; 132,-135056.64;
          134,-112829.07; 136,-127808.52; 138,-120077.19; 140,-124667.66; 142,-111137.84;
          144,-122010.02; 146,-125150.87; 148,-122251.62; 150,-123701.25; 152,-126358.89;
          154,-128533.33; 156,-122734.83; 158,-120802; 160,-115969.92; 162,-116936.34;
          164,-120560.4; 166,-116453.13; 168,-124184.46; 170,-128291.72; 172,-121768.42;
          174,-122251.62; 176,-128050.12; 178,-122734.83; 180,-123942.85; 182,-123701.25;
          184,-119352.38; 186,-124667.66; 188,-121043.6; 190,-121043.6])
      "#12负荷"
      annotation (Placement(transformation(extent={{92,-288},{72,-268}})));
    Modelica.Blocks.Sources.RealExpression realExpression25(y=time/3600)
      annotation (Placement(transformation(extent={{120,-288},{100,-268}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible22(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={90,-326})));

    Modelica.Blocks.Sources.Constant const22(k=0.531860)
      annotation (Placement(transformation(extent={{116,-352},{102,-338}})));
    Pipe pipe41(Length=150, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={154,-374})));
    Pipe pipe42(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={232,-350})));
    User F14(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.125,
      mflow_start=10)   "14栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={198,-306})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible23(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={200,-282})));

    Modelica.Blocks.Tables.CombiTable1Ds F14oad(table=[0,-233244; 2,-235752; 4,
          -242440; 6,-246202; 8,-252472; 10,-252472; 12,-241604; 14,-232826; 16,
          -231154; 18,-237842; 20,-231572; 22,-235334; 24,-222794; 26,-217778;
          28,-214016; 30,-202730; 32,-213598; 34,-202730; 36,-221958; 38,-183502;
          40,-192280; 42,-195624; 44,-194370; 46,-202312; 48,-211090; 50,-201476;
          52,-199804; 54,-200640; 56,-198968; 58,-193534; 60,-218196; 62,-198968;
          64,-186846; 66,-207328; 68,-203984; 70,-184756; 72,-183920; 74,-201058;
          76,-203984; 78,-193952; 80,-206074; 82,-199386; 84,-196878; 86,-203148;
          88,-210672; 90,-211926; 92,-192280; 94,-210254; 96,-201058; 98,-196878;
          100,-204820; 102,-198550; 104,-204402; 106,-230318; 108,-216524; 110,
          -203566; 112,-208582; 114,-204820; 116,-198550; 118,-206074; 120,-222794;
          122,-197714; 124,-206492; 126,-211926; 128,-238678; 130,-214852; 132,
          -233662; 134,-195206; 136,-221122; 138,-207746; 140,-215688; 142,-192280;
          144,-211090; 146,-216524; 148,-211508; 150,-214016; 152,-218614; 154,
          -222376; 156,-212344; 158,-209000; 160,-200640; 162,-202312; 164,-208582;
          166,-201476; 168,-214852; 170,-221958; 172,-210672; 174,-211508; 176,
          -221540; 178,-212344; 180,-214434; 182,-214016; 184,-206492; 186,-215688;
          188,-209418; 190,-209418])
      "#14负荷"
      annotation (Placement(transformation(extent={{170,-338},{190,-318}})));
    Modelica.Blocks.Sources.RealExpression realExpression26(y=time/3600)
      annotation (Placement(transformation(extent={{138,-338},{158,-318}})));
    Modelica.Blocks.Sources.Constant const23(k=0.638538)
      annotation (Placement(transformation(extent={{166,-274},{180,-260}})));
    Pipe pipe43(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,10},{10,-10}},
          rotation=-90,
          origin={232,-412})));
    User F15(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.125,
      mflow_start=10)   "15栋" annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=0,
          origin={186,-432})));
    Modelica.Blocks.Tables.CombiTable1Ds F15_load(table=[0,-233244; 2,-235752;
          4,-242440; 6,-246202; 8,-252472; 10,-252472; 12,-241604; 14,-232826;
          16,-231154; 18,-237842; 20,-231572; 22,-235334; 24,-222794; 26,-217778;
          28,-214016; 30,-202730; 32,-213598; 34,-202730; 36,-221958; 38,-183502;
          40,-192280; 42,-195624; 44,-194370; 46,-202312; 48,-211090; 50,-201476;
          52,-199804; 54,-200640; 56,-198968; 58,-193534; 60,-218196; 62,-198968;
          64,-186846; 66,-207328; 68,-203984; 70,-184756; 72,-183920; 74,-201058;
          76,-203984; 78,-193952; 80,-206074; 82,-199386; 84,-196878; 86,-203148;
          88,-210672; 90,-211926; 92,-192280; 94,-210254; 96,-201058; 98,-196878;
          100,-204820; 102,-198550; 104,-204402; 106,-230318; 108,-216524; 110,
          -203566; 112,-208582; 114,-204820; 116,-198550; 118,-206074; 120,-222794;
          122,-197714; 124,-206492; 126,-211926; 128,-238678; 130,-214852; 132,
          -233662; 134,-195206; 136,-221122; 138,-207746; 140,-215688; 142,-192280;
          144,-211090; 146,-216524; 148,-211508; 150,-214016; 152,-218614; 154,
          -222376; 156,-212344; 158,-209000; 160,-200640; 162,-202312; 164,-208582;
          166,-201476; 168,-214852; 170,-221958; 172,-210672; 174,-211508; 176,
          -221540; 178,-212344; 180,-214434; 182,-214016; 184,-206492; 186,-215688;
          188,-209418; 190,-209418])
      "#15负荷"
      annotation (Placement(transformation(extent={{160,-422},{180,-402}})));
    Modelica.Blocks.Sources.RealExpression realExpression27(y=time/3600)
      annotation (Placement(transformation(extent={{128,-422},{148,-402}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible24(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=0,
          origin={192,-458})));

    Modelica.Blocks.Sources.Constant const24(k=0.500000)
      annotation (Placement(transformation(extent={{162,-482},{176,-468}})));
    Pipe pipe44(Length=60, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-434})));
    Pipe pipe45(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-96,-468})));
    User F16(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.125,
      mflow_start=10)   "16栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-32,-466})));
    Modelica.Blocks.Tables.CombiTable1Ds F16_load(table=[0,-233244; 2,-235752;
          4,-242440; 6,-246202; 8,-252472; 10,-252472; 12,-241604; 14,-232826;
          16,-231154; 18,-237842; 20,-231572; 22,-235334; 24,-222794; 26,-217778;
          28,-214016; 30,-202730; 32,-213598; 34,-202730; 36,-221958; 38,-183502;
          40,-192280; 42,-195624; 44,-194370; 46,-202312; 48,-211090; 50,-201476;
          52,-199804; 54,-200640; 56,-198968; 58,-193534; 60,-218196; 62,-198968;
          64,-186846; 66,-207328; 68,-203984; 70,-184756; 72,-183920; 74,-201058;
          76,-203984; 78,-193952; 80,-206074; 82,-199386; 84,-196878; 86,-203148;
          88,-210672; 90,-211926; 92,-192280; 94,-210254; 96,-201058; 98,-196878;
          100,-204820; 102,-198550; 104,-204402; 106,-230318; 108,-216524; 110,
          -203566; 112,-208582; 114,-204820; 116,-198550; 118,-206074; 120,-222794;
          122,-197714; 124,-206492; 126,-211926; 128,-238678; 130,-214852; 132,
          -233662; 134,-195206; 136,-221122; 138,-207746; 140,-215688; 142,-192280;
          144,-211090; 146,-216524; 148,-211508; 150,-214016; 152,-218614; 154,
          -222376; 156,-212344; 158,-209000; 160,-200640; 162,-202312; 164,-208582;
          166,-201476; 168,-214852; 170,-221958; 172,-210672; 174,-211508; 176,
          -221540; 178,-212344; 180,-214434; 182,-214016; 184,-206492; 186,-215688;
          188,-209418; 190,-209418])
      "#16负荷"
      annotation (Placement(transformation(extent={{2,-458},{-18,-438}})));
    Modelica.Blocks.Sources.RealExpression realExpression28(y=time/3600)
      annotation (Placement(transformation(extent={{30,-458},{10,-438}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible25(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-30,-498})));

    Modelica.Blocks.Sources.Constant const25(k=0.500000)
      annotation (Placement(transformation(extent={{2,-524},{-12,-510}})));
    Pipe pipe46(Length=12, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-194,-472})));
    User F17(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.125,
      mflow_start=10)   "17栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-242,-496})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible26(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-244,-470})));

    Modelica.Blocks.Sources.Constant const26(k=0.731250)
      annotation (Placement(transformation(extent={{-264,-460},{-250,-446}})));
    Modelica.Blocks.Tables.CombiTable1Ds F17_load(table=[0,-233244; 2,-235752;
          4,-242440; 6,-246202; 8,-252472; 10,-252472; 12,-241604; 14,-232826;
          16,-231154; 18,-237842; 20,-231572; 22,-235334; 24,-222794; 26,-217778;
          28,-214016; 30,-202730; 32,-213598; 34,-202730; 36,-221958; 38,-183502;
          40,-192280; 42,-195624; 44,-194370; 46,-202312; 48,-211090; 50,-201476;
          52,-199804; 54,-200640; 56,-198968; 58,-193534; 60,-218196; 62,-198968;
          64,-186846; 66,-207328; 68,-203984; 70,-184756; 72,-183920; 74,-201058;
          76,-203984; 78,-193952; 80,-206074; 82,-199386; 84,-196878; 86,-203148;
          88,-210672; 90,-211926; 92,-192280; 94,-210254; 96,-201058; 98,-196878;
          100,-204820; 102,-198550; 104,-204402; 106,-230318; 108,-216524; 110,
          -203566; 112,-208582; 114,-204820; 116,-198550; 118,-206074; 120,-222794;
          122,-197714; 124,-206492; 126,-211926; 128,-238678; 130,-214852; 132,
          -233662; 134,-195206; 136,-221122; 138,-207746; 140,-215688; 142,-192280;
          144,-211090; 146,-216524; 148,-211508; 150,-214016; 152,-218614; 154,
          -222376; 156,-212344; 158,-209000; 160,-200640; 162,-202312; 164,-208582;
          166,-201476; 168,-214852; 170,-221958; 172,-210672; 174,-211508; 176,
          -221540; 178,-212344; 180,-214434; 182,-214016; 184,-206492; 186,-215688;
          188,-209418; 190,-209418])
      "#17负荷"
      annotation (Placement(transformation(extent={{-266,-532},{-246,-512}})));
    Modelica.Blocks.Sources.RealExpression realExpression29(y=time/3600)
      annotation (Placement(transformation(extent={{-244,-556},{-264,-536}})));
    Pipe pipe47(Length=72 + 66 + 132, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=0,
          origin={-260,-138})));
    User F19(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.15,
      mflow_start=16)   "19栋" annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=0,
          origin={-364,-320})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible27(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=0,
          origin={-360,-358})));

    Modelica.Blocks.Sources.Constant const27(k=0.835058)
      annotation (Placement(transformation(extent={{-392,-384},{-378,-370}})));
    Modelica.Blocks.Tables.CombiTable1Ds F19_load(table=[0,-373190.4; 2,-377203.2;
          4,-387904; 6,-393923.2; 8,-403955.2; 10,-403955.2; 12,-386566.4; 14,-372521.6;
          16,-369846.4; 18,-380547.2; 20,-370515.2; 22,-376534.4; 24,-356470.4;
          26,-348444.8; 28,-342425.6; 30,-324368; 32,-341756.8; 34,-324368; 36,
          -355132.8; 38,-293603.2; 40,-307648; 42,-312998.4; 44,-310992; 46,-323699.2;
          48,-337744; 50,-322361.6; 52,-319686.4; 54,-321024; 56,-318348.8; 58,
          -309654.4; 60,-349113.6; 62,-318348.8; 64,-298953.6; 66,-331724.8; 68,
          -326374.4; 70,-295609.6; 72,-294272; 74,-321692.8; 76,-326374.4; 78,-310323.2;
          80,-329718.4; 82,-319017.6; 84,-315004.8; 86,-325036.8; 88,-337075.2;
          90,-339081.6; 92,-307648; 94,-336406.4; 96,-321692.8; 98,-315004.8;
          100,-327712; 102,-317680; 104,-327043.2; 106,-368508.8; 108,-346438.4;
          110,-325705.6; 112,-333731.2; 114,-327712; 116,-317680; 118,-329718.4;
          120,-356470.4; 122,-316342.4; 124,-330387.2; 126,-339081.6; 128,-381884.8;
          130,-343763.2; 132,-373859.2; 134,-312329.6; 136,-353795.2; 138,-332393.6;
          140,-345100.8; 142,-307648; 144,-337744; 146,-346438.4; 148,-338412.8;
          150,-342425.6; 152,-349782.4; 154,-355801.6; 156,-339750.4; 158,-334400;
          160,-321024; 162,-323699.2; 164,-333731.2; 166,-322361.6; 168,-343763.2;
          170,-355132.8; 172,-337075.2; 174,-338412.8; 176,-354464; 178,-339750.4;
          180,-343094.4; 182,-342425.6; 184,-330387.2; 186,-345100.8; 188,-335068.8;
          190,-335068.8])
      "#19负荷"
      annotation (Placement(transformation(extent={{-404,-314},{-384,-294}})));
    Modelica.Blocks.Sources.RealExpression realExpression3(y=time/3600)
      annotation (Placement(transformation(extent={{-448,-314},{-428,-294}})));
    Modelica.Fluid.Sensors.Temperature temperature8(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-144,212},{-164,232}})));
    Modelica.Fluid.Sensors.Pressure pressure7(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-148,202},{-168,182}})));
    Modelica.Fluid.Sensors.Temperature temperature9(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-106,64},{-126,44}})));
    Modelica.Fluid.Sensors.Pressure pressure8(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-82,62},{-102,42}})));
    Modelica.Fluid.Sensors.Temperature temperature10(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-56,212},{-76,232}})));
    Modelica.Fluid.Sensors.Pressure pressure9(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-64,204},{-84,184}})));
    Modelica.Fluid.Sensors.Temperature temperature11(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{34,214},{14,234}})));
    Modelica.Fluid.Sensors.Pressure pressure10(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{30,206},{10,186}})));
    Modelica.Fluid.Sensors.Temperature temperature12(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{114,214},{94,234}})));
    Modelica.Fluid.Sensors.Pressure pressure11(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{110,206},{90,186}})));
    Modelica.Fluid.Sensors.Temperature temperature14(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{342,212},{322,232}})));
    Modelica.Fluid.Sensors.Pressure pressure13(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{338,204},{318,184}})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate3(redeclare package
        Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater) annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={-130,254})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate4(redeclare package
        Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater) annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={-46,256})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate5(redeclare package
        Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater) annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={46,258})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate6(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={128,264})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate8(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={356,264})));
    Modelica.Fluid.Sensors.Temperature temperature15(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-160,272},{-140,292}})));
    Modelica.Fluid.Sensors.Pressure pressure14(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-142,274},{-122,294}})));
    Modelica.Fluid.Sensors.Temperature temperature16(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-74,282},{-54,302}})));
    Modelica.Fluid.Sensors.Pressure pressure15(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-56,284},{-36,304}})));
    Modelica.Fluid.Sensors.Temperature temperature17(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{14,278},{34,298}})));
    Modelica.Fluid.Sensors.Pressure pressure16(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{32,280},{52,300}})));
    Modelica.Fluid.Sensors.Temperature temperature18(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{100,286},{120,306}})));
    Modelica.Fluid.Sensors.Pressure pressure17(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{118,288},{138,308}})));
    Modelica.Fluid.Sensors.Temperature temperature20(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{328,288},{348,308}})));
    Modelica.Fluid.Sensors.Pressure pressure19(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{346,290},{366,310}})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate9(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={-26,80})));
    Modelica.Fluid.Sensors.Temperature temperature21(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-76,112},{-96,132}})));
    Modelica.Fluid.Sensors.Pressure pressure20(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-58,106},{-78,126}})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate10(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={264,104})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate11(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={-20,-18})));
    Modelica.Fluid.Sensors.Temperature temperature22(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-94,-46},{-114,-66}})));
    Modelica.Fluid.Sensors.Pressure pressure21(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-72,-42},{-92,-62}})));
    Modelica.Fluid.Sensors.Temperature temperature23(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-184,90},{-204,110}})));
    Modelica.Fluid.Sensors.Temperature temperature24(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-182,36},{-202,16}})));
    Modelica.Fluid.Sensors.Pressure pressure23(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-158,34},{-178,14}})));
    Modelica.Fluid.Sensors.Temperature temperature25(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-88,6},{-108,26}})));
    Modelica.Fluid.Sensors.Pressure pressure24(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-68,6},{-88,26}})));
    Modelica.Fluid.Sensors.Temperature temperature26(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-78,-102},{-98,-82}})));
    Modelica.Fluid.Sensors.Pressure pressure25(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-60,-102},{-80,-82}})));
    Modelica.Fluid.Sensors.Temperature temperature27(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-104,-140},{-124,-160}})));
    Modelica.Fluid.Sensors.Pressure pressure26(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-82,-136},{-102,-156}})));
    Modelica.Fluid.Sensors.Temperature temperature28(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-100,-268},{-120,-288}})));
    Modelica.Fluid.Sensors.Pressure pressure27(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-78,-264},{-98,-284}})));
    Modelica.Fluid.Sensors.Temperature temperature29(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{132,-192},{112,-212}})));
    Modelica.Fluid.Sensors.Pressure pressure28(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{112,-192},{92,-212}})));
    Modelica.Fluid.Sensors.Temperature temperature30(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{16,-306},{-4,-326}})));
    Modelica.Fluid.Sensors.Pressure pressure29(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{38,-302},{18,-322}})));
    Modelica.Fluid.Sensors.Temperature temperature31(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{62,-338},{42,-358}})));
    Modelica.Fluid.Sensors.Pressure pressure30(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{84,-334},{64,-354}})));
    Modelica.Fluid.Sensors.Temperature temperature32(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{212,-340},{192,-360}})));
    Modelica.Fluid.Sensors.Pressure pressure31(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{230,-332},{210,-352}})));
    Modelica.Fluid.Sensors.Temperature temperature33(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{260,-288},{240,-308}})));
    Modelica.Fluid.Sensors.Pressure pressure32(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{282,-284},{262,-304}})));
    Modelica.Fluid.Sensors.Temperature temperature34(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{226,-474},{206,-494}})));
    Modelica.Fluid.Sensors.Pressure pressure33(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{244,-466},{224,-486}})));
    Modelica.Fluid.Sensors.Temperature temperature35(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{206,-414},{186,-394}})));
    Modelica.Fluid.Sensors.Pressure pressure34(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{228,-410},{208,-390}})));
    Modelica.Fluid.Sensors.Temperature temperature36(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-68,-454},{-88,-434}})));
    Modelica.Fluid.Sensors.Pressure pressure35(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-42,-456},{-62,-436}})));
    Modelica.Fluid.Sensors.Temperature temperature37(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-66,-510},{-86,-530}})));
    Modelica.Fluid.Sensors.Pressure pressure36(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-40,-506},{-60,-526}})));
    Modelica.Fluid.Sensors.Temperature temperature38(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-74,-216},{-94,-196}})));
    Modelica.Fluid.Sensors.Pressure pressure37(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-54,-218},{-74,-198}})));
    Modelica.Fluid.Sensors.Temperature temperature39(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{128,-172},{108,-152}})));
    Modelica.Fluid.Sensors.Pressure pressure38(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{148,-174},{128,-154}})));
    Modelica.Fluid.Sensors.Temperature temperature40(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-208,-506},{-228,-526}})));
    Modelica.Fluid.Sensors.Pressure pressure39(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-182,-502},{-202,-522}})));
    Modelica.Fluid.Sensors.Temperature temperature41(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-222,-452},{-242,-432}})));
    Modelica.Fluid.Sensors.Pressure pressure40(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-198,-454},{-218,-434}})));
    Modelica.Fluid.Sensors.Temperature temperature42(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-206,-218},{-226,-198}})));
    Modelica.Fluid.Sensors.Pressure pressure41(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-186,-230},{-206,-210}})));
    Modelica.Fluid.Sensors.Temperature temperature43(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-198,-264},{-218,-284}})));
    Modelica.Fluid.Sensors.Pressure pressure42(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-176,-260},{-196,-280}})));
    Modelica.Fluid.Sensors.Temperature temperature44(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-214,-316},{-234,-296}})));
    Modelica.Fluid.Sensors.Pressure pressure43(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-192,-318},{-212,-298}})));
    Modelica.Fluid.Sensors.Temperature temperature45(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-212,-356},{-232,-376}})));
    Modelica.Fluid.Sensors.Pressure pressure44(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-186,-352},{-206,-372}})));
    Modelica.Fluid.Sensors.Temperature temperature46(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-326,-372},{-346,-392}})));
    Modelica.Fluid.Sensors.Pressure pressure45(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-300,-368},{-320,-388}})));
    Modelica.Fluid.Sensors.Temperature temperature47(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-340,-310},{-360,-290}})));
    Modelica.Fluid.Sensors.Pressure pressure46(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-318,-314},{-338,-294}})));
    Pipe pipe48(Length=12, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={232,198})));
    User F2(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=5.78) "2栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={208,256})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible11(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={214,280})));
    Modelica.Blocks.Tables.CombiTable1Ds F2_2oad(table=[0,-134815.03; 2,-136264.66;
          4,-140130.32; 6,-142304.76; 8,-145928.82; 10,-145928.82; 12,-139647.11;
          14,-134573.43; 16,-133607.01; 18,-137472.68; 20,-133848.62; 22,-136023.05;
          24,-128774.93; 26,-125875.68; 28,-123701.25; 30,-117177.94; 32,-123459.64;
          34,-117177.94; 36,-128291.72; 38,-106064.16; 40,-111137.84; 42,-113070.67;
          44,-112345.86; 46,-116936.34; 48,-122010.02; 50,-116453.13; 52,-115486.71;
          54,-115969.92; 56,-115003.5; 58,-111862.65; 60,-126117.29; 62,-115003.5;
          64,-107996.99; 66,-119835.58; 68,-117902.75; 70,-106788.97; 72,-106305.76;
          74,-116211.52; 76,-117902.75; 78,-112104.26; 80,-119110.77; 82,-115245.11;
          84,-113795.48; 86,-117419.54; 88,-121768.42; 90,-122493.23; 92,-111137.84;
          94,-121526.81; 96,-116211.52; 98,-113795.48; 100,-118385.96; 102,-114761.9;
          104,-118144.36; 106,-133123.8; 108,-125150.87; 110,-117661.15; 112,-120560.4;
          114,-118385.96; 116,-114761.9; 118,-119110.77; 120,-128774.93; 122,-114278.69;
          124,-119352.38; 126,-122493.23; 128,-137955.88; 130,-124184.46; 132,-135056.64;
          134,-112829.07; 136,-127808.52; 138,-120077.19; 140,-124667.66; 142,-111137.84;
          144,-122010.02; 146,-125150.87; 148,-122251.62; 150,-123701.25; 152,-126358.89;
          154,-128533.33; 156,-122734.83; 158,-120802; 160,-115969.92; 162,-116936.34;
          164,-120560.4; 166,-116453.13; 168,-124184.46; 170,-128291.72; 172,-121768.42;
          174,-122251.62; 176,-128050.12; 178,-122734.83; 180,-123942.85; 182,-123701.25;
          184,-119352.38; 186,-124667.66; 188,-121043.6; 190,-121043.6])
                            "#2负荷"
      annotation (Placement(transformation(extent={{180,228},{200,248}})));
    Modelica.Blocks.Sources.RealExpression realExpression14(y=time/3600)
      annotation (Placement(transformation(extent={{188,200},{168,220}})));
    Modelica.Blocks.Sources.Constant const11(k=1.000000)
      annotation (Placement(transformation(extent={{186,290},{200,304}})));
    Modelica.Fluid.Sensors.Temperature temperature48(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{234,216},{214,236}})));
    Modelica.Fluid.Sensors.Pressure pressure47(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{226,214},{206,194}})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate12(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={246,266})));
    Modelica.Fluid.Sensors.Temperature temperature49(redeclare package Medium
        = Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{218,290},{238,310}})));
    Modelica.Fluid.Sensors.Pressure pressure48(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{236,292},{256,312}})));
    Modelica.Fluid.Sensors.Temperature temperature2(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={188,106})));
    Modelica.Fluid.Sensors.Pressure pressure1(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=270,
          origin={184,88})));
    Modelica.Fluid.Sensors.Temperature temperature3(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={264,32})));
    Modelica.Fluid.Sensors.Pressure pressure2(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=270,
          origin={258,14})));
    Modelica.Fluid.Sensors.Temperature temperature4(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=180,
          origin={220,-44})));
    Modelica.Fluid.Sensors.Pressure pressure3(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=90,
          origin={242,-14})));
    Modelica.Fluid.Sensors.Pressure pressure4(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-302,-64},{-282,-44}})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate1(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={-14,-126})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate2(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=180,
          origin={-248,52})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate7(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={164,-10})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate13(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={328,38})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate14(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-324,-32})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate15(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-262,-246})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate16(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={-22,-246})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate17(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={196,-198})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate18(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={164,-294})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate19(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={110,-308})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate20(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={-398,-338})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate21(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-278,-484})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate22(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={0,-480})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate23(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=270,
          origin={148,-444})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate24(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-278,-336})));
    Modelica.Fluid.Sensors.Temperature temperature5(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=0,
          origin={252,142})));
    Modelica.Fluid.Sensors.Pressure pressure5(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=90,
          origin={274,130})));
    Modelica.Fluid.Sensors.Pressure pressure6(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=180,
          origin={196,26})));
    Modelica.Fluid.Sensors.Temperature temperature6(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=0,
          origin={210,28})));
    Modelica.Fluid.Sensors.Temperature temperature7(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=0,
          origin={276,72})));
    Modelica.Fluid.Sensors.Pressure pressure12(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=180,
          origin={292,72})));
    Modelica.Fluid.Sensors.Pressure pressure22(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-162,90},{-182,110}})));
  equation
    connect(mflow.u, realExpression15.y)
      annotation (Line(points={{-330,2},{-323,2}}, color={0,0,127}));
    connect(pipe.port_b1, boundary1.ports[1]) annotation (Line(points={{-248,
            -36},{-274,-36},{-274,-70},{-329.333,-70}},
                                color={0,127,255}));
    connect(pump.port_a, boundary.ports[1])
      annotation (Line(points={{-388,-32},{-416,-32}},
                                                   color={0,127,255}));
    connect(temperature1.port, pump.port_a) annotation (Line(points={{-404,-22},
            {-404,-32},{-388,-32}},     color={0,127,255}));
    connect(Tg.u,realExpression13. y)
      annotation (Line(points={{-470,-36},{-481,-36}},
                                                   color={0,0,127}));
    connect(Tg.y[1], boundary.T_in)
      annotation (Line(points={{-447,-36},{-438,-36}},
                                                   color={0,0,127}));
    connect(temperature.port, boundary1.ports[2])
      annotation (Line(points={{-266,-70},{-328,-70}}, color={0,127,255}));
    connect(pipe.port_b, pipe1.port_a) annotation (Line(points={{-228,-32},{-220,-32},
            {-220,-12},{-192,-12}}, color={0,127,255}));
    connect(pipe.port_a1, pipe1.port_b1) annotation (Line(points={{-228,-36},{-216,
            -36},{-216,-16},{-192,-16}}, color={0,127,255}));
    connect(pipe.port_b, pipe2.port_a) annotation (Line(points={{-228,-32},{-220,-32},
            {-220,-52},{-190,-52}}, color={0,127,255}));
    connect(pipe.port_a1, pipe2.port_b1) annotation (Line(points={{-228,-36},{-216,
            -36},{-216,-56},{-190,-56}}, color={0,127,255}));
    connect(pipe1.port_b, pipe3.port_a) annotation (Line(points={{-172,-12},{-154,
            -12},{-154,6}}, color={0,127,255}));
    connect(pipe1.port_a1, pipe3.port_b1) annotation (Line(points={{-172,-16},{-150,
            -16},{-150,6}}, color={0,127,255}));
    connect(pipe2.port_b, pipe4.port_a) annotation (Line(points={{-170,-52},{-138,
            -52},{-138,-32}}, color={0,127,255}));
    connect(pipe2.port_a1, pipe4.port_b1) annotation (Line(points={{-170,-56},{-134,
            -56},{-134,-32}}, color={0,127,255}));
    connect(realExpression8.y, F8_load.u)
      annotation (Line(points={{-29,14},{-34,14}}, color={0,0,127}));
    connect(F8_load.y[1], F8.Q)
      annotation (Line(points={{-57,14},{-62,14},{-62,4}}, color={0,0,127}));
    connect(const4.y, valveIncompressible4.opening) annotation (Line(points={{-50.7,
            -53},{-60,-53},{-60,-44}}, color={0,0,127}));
    connect(realExpression1.y, F5_load1.u)
      annotation (Line(points={{-235,28},{-230,28}}, color={0,0,127}));
    connect(F5_load1.y[1], F5.Q)
      annotation (Line(points={{-207,28},{-204,28},{-204,42}}, color={0,0,127}));
    connect(const1.y, valveIncompressible1.opening) annotation (Line(points={{-217.3,
            87},{-208,87},{-208,78}}, color={0,0,127}));
    connect(pipe4.port_b, pipe6.port_a) annotation (Line(points={{-138,-12},{-138,
            -2},{-112,-2}}, color={0,127,255}));
    connect(pipe6.port_b, F8.port_a)
      annotation (Line(points={{-92,-2},{-72,-2}}, color={0,127,255}));
    connect(pipe6.port_a1, valveIncompressible4.port_b) annotation (Line(points={{-92,-6},
            {-80,-6},{-80,-36},{-70,-36}},         color={0,127,255}));
    connect(valveIncompressible1.port_b, pipe7.port_a1) annotation (Line(points={{
            -198,70},{-186,70},{-186,52},{-180,52}}, color={0,127,255}));
    connect(pipe7.port_b1, pipe3.port_a1) annotation (Line(points={{-160,52},{-150,
            52},{-150,26}}, color={0,127,255}));
    connect(pipe7.port_a, pipe3.port_b) annotation (Line(points={{-160,48},{-154,48},
            {-154,26}}, color={0,127,255}));
    connect(F5.port_a, pipe7.port_b)
      annotation (Line(points={{-194,48},{-180,48}}, color={0,127,255}));
    connect(pipe8.port_a, pipe3.port_b)
      annotation (Line(points={{-154,62},{-154,26}}, color={0,127,255}));
    connect(pipe8.port_b1, pipe3.port_a1)
      annotation (Line(points={{-150,62},{-150,26}}, color={0,127,255}));
    connect(realExpression4.y, F6_load.u)
      annotation (Line(points={{-17,120},{-22,120}}, color={0,0,127}));
    connect(F6_load.y[1], F6.Q)
      annotation (Line(points={{-45,120},{-46,120},{-46,102}}, color={0,0,127}));
    connect(const2.y, valveIncompressible2.opening) annotation (Line(points={{-60.7,
            47},{-64,47},{-64,58}},            color={0,0,127}));
    connect(pipe9.port_b, F6.port_a)
      annotation (Line(points={{-96,96},{-56,96}}, color={0,127,255}));
    connect(pipe9.port_a1, valveIncompressible2.port_b) annotation (Line(points={{
            -96,92},{-84,92},{-84,66},{-74,66}}, color={0,127,255}));
    connect(pipe8.port_a1, pipe9.port_b1) annotation (Line(points={{-150,82},{-150,
            92},{-116,92}}, color={0,127,255}));
    connect(pipe8.port_b, pipe9.port_a) annotation (Line(points={{-154,82},{-154,96},
            {-116,96}}, color={0,127,255}));
    connect(pipe10.port_b1, pipe9.port_b1) annotation (Line(points={{-150,110},{-150,
            92},{-116,92}}, color={0,127,255}));
    connect(pipe10.port_a, pipe8.port_b)
      annotation (Line(points={{-154,110},{-154,82}}, color={0,127,255}));
    connect(pipe10.port_b, pipe11.port_a) annotation (Line(points={{-154,130},{
            -154,178},{-144,178},{-144,184}},
                                         color={0,127,255}));
    connect(pipe10.port_b, pipe12.port_a) annotation (Line(points={{-154,130},{
            -154,178},{-62,178},{-62,184}},
                                       color={0,127,255}));
    connect(pipe11.port_b1, pipe10.port_a1) annotation (Line(points={{-140,184},
            {-140,174},{-150,174},{-150,130}},
                                         color={0,127,255}));
    connect(pipe12.port_b1, pipe10.port_a1) annotation (Line(points={{-58,184},
            {-58,174},{-150,174},{-150,130}},
                                         color={0,127,255}));
    connect(F4_1.port_a, pipe11.port_b) annotation (Line(points={{-154,244},{
            -144,244},{-144,204}},
                              color={0,127,255}));
    connect(valveIncompressible3.port_a, F4_1.port_b) annotation (Line(points={{-176,
            268},{-192,268},{-192,244},{-174,244}}, color={0,127,255}));
    connect(realExpression5.y, F4_1_load.u) annotation (Line(points={{-211,206},
            {-211,217},{-212,217},{-212,228}},
                                         color={0,0,127}));
    connect(F4_1_load.y[1], F4_1.Q) annotation (Line(points={{-189,228},{-176,
            228},{-176,238},{-164,238}},
                                    color={0,0,127}));
    connect(const3.y, valveIncompressible3.opening) annotation (Line(points={{-179.3,
            285},{-166,285},{-166,276}}, color={0,0,127}));
    connect(realExpression6.y, F4_1_load1.u) annotation (Line(points={{-101,210},
            {-106,210},{-106,232},{-104,232}},color={0,0,127}));
    connect(F4_1_load1.y[1], F4_2.Q)
      annotation (Line(points={{-81,232},{-76,232},{-76,246}}, color={0,0,127}));
    connect(const5.y, valveIncompressible5.opening) annotation (Line(points={{-79.3,
            297},{-78,297},{-78,284}},           color={0,0,127}));
    connect(valveIncompressible5.port_a, F4_2.port_b) annotation (Line(points={{-88,276},
            {-94,276},{-94,252},{-86,252}},        color={0,127,255}));
    connect(F4_2.port_a, pipe12.port_b) annotation (Line(points={{-66,252},{-62,
            252},{-62,204}},
                        color={0,127,255}));
    connect(pipe13.port_b1, pipe10.port_a1) annotation (Line(points={{-36,174},{-150,
            174},{-150,130}}, color={0,127,255}));
    connect(pipe10.port_b, pipe13.port_a) annotation (Line(points={{-154,130},{-154,
            178},{-36,178}}, color={0,127,255}));
    connect(F3_1.port_a, pipe14.port_b)
      annotation (Line(points={{24,248},{34,248},{34,208}},color={0,127,255}));
    connect(F3_1_load.y[1], F3_1.Q)
      annotation (Line(points={{11,228},{14,228},{14,242}}, color={0,0,127}));
    connect(const6.y, valveIncompressible6.opening)
      annotation (Line(points={{-1.3,289},{12,289},{12,280}},  color={0,0,127}));
    connect(F3_2_load.y[1], F3_2.Q)
      annotation (Line(points={{93,236},{98,236},{98,250}}, color={0,0,127}));
    connect(const7.y, valveIncompressible7.opening)
      annotation (Line(points={{90.7,297},{96,297},{96,288}}, color={0,0,127}));
    connect(F3_2.port_a, pipe15.port_b)
      annotation (Line(points={{108,256},{112,256},{112,208}},
                                                            color={0,127,255}));
    connect(F3_1_load.u, realExpression7.y) annotation (Line(points={{-12,228},
            {-18,228},{-18,206},{-11,206}},
                                       color={0,0,127}));
    connect(F3_2_load.u, realExpression9.y) annotation (Line(points={{70,236},{
            64,236},{64,214},{73,214}}, color={0,0,127}));
    connect(valveIncompressible6.port_a, F3_1.port_b) annotation (Line(points={{2,272},
            {-2,272},{-2,248},{4,248}},          color={0,127,255}));
    connect(valveIncompressible7.port_a, F3_2.port_b) annotation (Line(points={{86,280},
            {84,280},{84,256},{88,256}},      color={0,127,255}));
    connect(pipe13.port_b, pipe15.port_a)
      annotation (Line(points={{-16,178},{112,178},{112,188}},
                                                             color={0,127,255}));
    connect(pipe15.port_b1, pipe13.port_a1)
      annotation (Line(points={{116,188},{116,174},{-16,174}},
                                                             color={0,127,255}));
    connect(pipe14.port_a, pipe15.port_a) annotation (Line(points={{34,188},{34,
            178},{112,178},{112,188}},
                                color={0,127,255}));
    connect(pipe14.port_b1, pipe13.port_a1)
      annotation (Line(points={{38,188},{38,174},{-16,174}}, color={0,127,255}));
    connect(pipe13.port_b, pipe16.port_a)
      annotation (Line(points={{-16,178},{128,178}}, color={0,127,255}));
    connect(pipe16.port_b1, pipe13.port_a1)
      annotation (Line(points={{128,174},{-16,174}}, color={0,127,255}));
    connect(pipe16.port_b, pipe18.port_a)
      annotation (Line(points={{148,178},{260,178}}, color={0,127,255}));
    connect(pipe18.port_b1, pipe16.port_a1)
      annotation (Line(points={{260,174},{148,174}}, color={0,127,255}));
    connect(F1oad.y[1], F1.Q) annotation (Line(points={{321,236},{326,236},{326,
            248}}, color={0,0,127}));
    connect(const9.y, valveIncompressible9.opening) annotation (Line(points={{310.7,
            295},{324,295},{324,286}}, color={0,0,127}));
    connect(F1.port_a, pipe19.port_b) annotation (Line(points={{336,254},{340,
            254},{340,206}},
                        color={0,127,255}));
    connect(F1oad.u, realExpression2.y) annotation (Line(points={{298,236},{294,
            236},{294,212},{301,212}}, color={0,0,127}));
    connect(valveIncompressible9.port_a,F1. port_b) annotation (Line(points={{314,278},
            {314,264},{316,264},{316,254}},      color={0,127,255}));
    connect(pipe18.port_b, pipe19.port_a) annotation (Line(points={{280,178},{
            340,178},{340,186}},
                             color={0,127,255}));
    connect(pipe18.port_a1, pipe19.port_b1) annotation (Line(points={{280,174},
            {344,174},{344,186}},
                             color={0,127,255}));
    connect(pipe20.port_b1, pipe16.port_a1) annotation (Line(points={{154,158},
            {154,174},{148,174}},
                             color={0,127,255}));
    connect(pipe20.port_a, pipe16.port_b) annotation (Line(points={{158,158},{
            158,178},{148,178}},
                             color={0,127,255}));
    connect(realExpression11.y, F7_load.u)
      annotation (Line(points={{191,146},{200,146}}, color={0,0,127}));
    connect(F7_load.y[1], F7.Q)
      annotation (Line(points={{223,146},{230,146},{230,130}}, color={0,0,127}));
    connect(const10.y, valveIncompressible10.opening) annotation (Line(points={{226.7,
            77},{226.7,80},{232,80},{232,86}}, color={0,0,127}));
    connect(pipe21.port_b, F7.port_a)
      annotation (Line(points={{200,124},{220,124}}, color={0,127,255}));
    connect(pipe21.port_a1, valveIncompressible10.port_b) annotation (Line(points
          ={{200,120},{212,120},{212,94},{222,94}}, color={0,127,255}));
    connect(pipe20.port_b, pipe21.port_a) annotation (Line(points={{158,138},{158,
            124},{180,124}}, color={0,127,255}));
    connect(pipe20.port_a1, pipe21.port_b1) annotation (Line(points={{154,138},{154,
            120},{180,120}}, color={0,127,255}));
    connect(pipe20.port_b, pipe22.port_a)
      annotation (Line(points={{158,138},{158,92}}, color={0,127,255}));
    connect(pipe20.port_a1, pipe22.port_b1)
      annotation (Line(points={{154,138},{154,92}}, color={0,127,255}));
    connect(pipe22.port_b, pipe23.port_a)
      annotation (Line(points={{158,72},{158,52},{182,52}}, color={0,127,255}));
    connect(pipe22.port_a1, pipe23.port_b1)
      annotation (Line(points={{154,72},{154,48},{182,48}}, color={0,127,255}));
    connect(pipe23.port_b, pipe24.port_a)
      annotation (Line(points={{202,52},{250,52}}, color={0,127,255}));
    connect(pipe23.port_a1, pipe24.port_b1)
      annotation (Line(points={{202,48},{250,48}}, color={0,127,255}));
    connect(pipe25.port_b1, pipe24.port_b1)
      annotation (Line(points={{224,34},{224,48},{250,48}}, color={0,127,255}));
    connect(pipe25.port_a, pipe24.port_a)
      annotation (Line(points={{220,34},{220,52},{250,52}}, color={0,127,255}));
    connect(realExpression12.y, F9_2_load.u)
      annotation (Line(points={{331,68},{338,68}}, color={0,0,127}));
    connect(F9_2_load.y[1], F9_2.Q)
      annotation (Line(points={{315,68},{310,68},{310,58}}, color={0,0,127}));
    connect(pipe24.port_b, F9_2.port_a)
      annotation (Line(points={{270,52},{300,52}}, color={0,127,255}));
    connect(pipe24.port_a1, valveIncompressible12.port_b) annotation (Line(points
          ={{270,48},{280,48},{280,26},{290,26}}, color={0,127,255}));
    connect(const12.y, valveIncompressible12.opening)
      annotation (Line(points={{296.7,9},{300,9},{300,18}}, color={0,0,127}));
    connect(realExpression16.y, F9_1_load.u)
      annotation (Line(points={{133,26},{150,26}}, color={0,0,127}));
    connect(F9_1_load.y[1], F9_1.Q)
      annotation (Line(points={{173,26},{180,26},{180,10}}, color={0,0,127}));
    connect(const13.y, valveIncompressible13.opening) annotation (Line(points={{194.7,
            -39},{194.7,-38},{198,-38},{198,-30}}, color={0,0,127}));
    connect(F9_1.port_a, pipe25.port_b)
      annotation (Line(points={{190,4},{220,4},{220,14}}, color={0,127,255}));
    connect(valveIncompressible13.port_b, pipe25.port_a1) annotation (Line(points
          ={{208,-22},{224,-22},{224,14}}, color={0,127,255}));
    connect(pipe2.port_b, pipe30.port_a) annotation (Line(points={{-170,-52},{-138,
            -52},{-138,-78}}, color={0,127,255}));
    connect(pipe2.port_a1, pipe30.port_b1) annotation (Line(points={{-170,-56},{-134,
            -56},{-134,-78}}, color={0,127,255}));
    connect(realExpression20.y, F10_load.u)
      annotation (Line(points={{-25,-92},{-30,-92}}, color={0,0,127}));
    connect(F10_load.y[1], F10.Q) annotation (Line(points={{-53,-92},{-58,-92},{-58,
            -102}}, color={0,0,127}));
    connect(const17.y, valveIncompressible17.opening) annotation (Line(points={{-61.3,
            -157},{-61.3,-152},{-56,-152},{-56,-146}}, color={0,0,127}));
    connect(pipe31.port_b, F10.port_a)
      annotation (Line(points={{-88,-108},{-68,-108}}, color={0,127,255}));
    connect(pipe31.port_a1, valveIncompressible17.port_b) annotation (Line(points={{-88,
            -112},{-82,-112},{-82,-138},{-66,-138}},      color={0,127,255}));
    connect(pipe30.port_b, pipe31.port_a) annotation (Line(points={{-138,-98},{-138,
            -108},{-108,-108}}, color={0,127,255}));
    connect(pipe30.port_a1, pipe31.port_b1) annotation (Line(points={{-134,-98},{-134,
            -112},{-108,-112}}, color={0,127,255}));
    connect(pipe30.port_b, pipe32.port_a)
      annotation (Line(points={{-138,-98},{-138,-140}}, color={0,127,255}));
    connect(pipe30.port_a1, pipe32.port_b1)
      annotation (Line(points={{-134,-98},{-134,-140}}, color={0,127,255}));
    connect(pipe32.port_a1, pipe33.port_b1) annotation (Line(points={{-134,-160},{
            -134,-186},{-54,-186}}, color={0,127,255}));
    connect(pipe32.port_b, pipe33.port_a) annotation (Line(points={{-138,-160},{-138,
            -182},{-54,-182}}, color={0,127,255}));
    connect(realExpression21.y, F13_load.u)
      annotation (Line(points={{197,-166},{186,-166}}, color={0,0,127}));
    connect(F13_load.y[1], F13.Q) annotation (Line(points={{163,-166},{158,-166},{
            158,-176}}, color={0,0,127}));
    connect(const18.y, valveIncompressible18.opening) annotation (Line(points={{154.7,
            -231},{154.7,-226},{160,-226},{160,-220}}, color={0,0,127}));
    connect(pipe33.port_b, F13.port_a)
      annotation (Line(points={{-34,-182},{148,-182}}, color={0,127,255}));
    connect(valveIncompressible18.port_b, pipe33.port_a1) annotation (Line(points
          ={{150,-212},{136,-212},{136,-186},{-34,-186}}, color={0,127,255}));
    connect(pipe32.port_b, pipe34.port_a)
      annotation (Line(points={{-138,-160},{-138,-202}}, color={0,127,255}));
    connect(pipe32.port_a1, pipe34.port_b1)
      annotation (Line(points={{-134,-160},{-134,-202}}, color={0,127,255}));
    connect(pipe34.port_b, pipe35.port_a) annotation (Line(points={{-138,-222},{-138,
            -230},{-104,-230}}, color={0,127,255}));
    connect(pipe34.port_a1, pipe35.port_b1) annotation (Line(points={{-134,-222},{
            -134,-234},{-104,-234}}, color={0,127,255}));
    connect(realExpression22.y, F12_load.u)
      annotation (Line(points={{-15,-214},{-22,-214}}, color={0,0,127}));
    connect(const19.y, valveIncompressible19.opening) annotation (Line(points={{-55.3,
            -281},{-55.3,-280},{-50,-280},{-50,-270}}, color={0,0,127}));
    connect(pipe35.port_b, F12.port_a)
      annotation (Line(points={{-84,-230},{-58,-230}}, color={0,127,255}));
    connect(F12_load.y[1], F12.Q) annotation (Line(points={{-45,-214},{-48,-214},
            {-48,-224}},color={0,0,127}));
    connect(valveIncompressible19.port_b, pipe35.port_a1) annotation (Line(points
          ={{-60,-262},{-66,-262},{-66,-234},{-84,-234}}, color={0,127,255}));
    connect(pipe34.port_b, pipe36.port_a)
      annotation (Line(points={{-138,-222},{-138,-276}}, color={0,127,255}));
    connect(pipe34.port_a1, pipe36.port_b1)
      annotation (Line(points={{-134,-222},{-134,-276}}, color={0,127,255}));
    connect(pipe37.port_a, pipe36.port_a) annotation (Line(points={{-174,-238},{-138,
            -238},{-138,-276}}, color={0,127,255}));
    connect(pipe37.port_b1, pipe35.port_b1)
      annotation (Line(points={{-174,-234},{-104,-234}}, color={0,127,255}));
    connect(F11.port_a, pipe37.port_b) annotation (Line(points={{-218,-258},{-208,
            -258},{-208,-238},{-194,-238}}, color={0,127,255}));
    connect(valveIncompressible20.port_b, pipe37.port_a1)
      annotation (Line(points={{-220,-234},{-194,-234}}, color={0,127,255}));
    connect(const20.y, valveIncompressible20.opening) annotation (Line(points={{-239.3,
            -215},{-230,-215},{-230,-226}}, color={0,0,127}));
    connect(realExpression23.y, F11_load.u)
      annotation (Line(points={{-261,-280},{-256,-280}}, color={0,0,127}));
    connect(F11_load.y[1], F11.Q) annotation (Line(points={{-233,-280},{-228,
            -280},{-228,-264}},
                          color={0,0,127}));
    connect(F18.port_a, pipe38.port_b) annotation (Line(points={{-234,-346},{
            -200,-346},{-200,-324},{-190,-324}},
                                            color={0,127,255}));
    connect(valveIncompressible21.port_b, pipe38.port_a1)
      annotation (Line(points={{-232,-320},{-190,-320}}, color={0,127,255}));
    connect(const21.y, valveIncompressible21.opening) annotation (Line(points={{-257.3,
            -303},{-246,-303},{-246,-312},{-242,-312}},   color={0,0,127}));
    connect(realExpression24.y, F18_load.u)
      annotation (Line(points={{-271,-390},{-282,-390},{-282,-370},{-276,-370}},
                                                         color={0,0,127}));
    connect(F18_load.y[1], F18.Q) annotation (Line(points={{-253,-370},{-244,
            -370},{-244,-352}},
                          color={0,0,127}));
    connect(pipe38.port_b1, pipe36.port_a1) annotation (Line(points={{-170,-320},
            {-134,-320},{-134,-296}},color={0,127,255}));
    connect(pipe36.port_b, pipe38.port_a) annotation (Line(points={{-138,-296},
            {-138,-324},{-170,-324}},
                                color={0,127,255}));
    connect(pipe36.port_b, pipe39.port_a)
      annotation (Line(points={{-138,-296},{-138,-338}}, color={0,127,255}));
    connect(pipe36.port_a1, pipe39.port_b1)
      annotation (Line(points={{-134,-296},{-134,-338}}, color={0,127,255}));
    connect(realExpression25.y, F12_2_load.u)
      annotation (Line(points={{99,-278},{94,-278}}, color={0,0,127}));
    connect(const22.y, valveIncompressible22.opening) annotation (Line(points={{101.3,
            -345},{90,-345},{90,-334}},             color={0,0,127}));
    connect(pipe40.port_b, F12_2.port_a) annotation (Line(points={{32,-372},{40,-372},
            {40,-294},{56,-294}}, color={0,127,255}));
    connect(valveIncompressible22.port_b, pipe40.port_a1) annotation (Line(points={{80,-326},
            {44,-326},{44,-376},{32,-376}},           color={0,127,255}));
    connect(pipe39.port_a1, pipe40.port_b1) annotation (Line(points={{-134,-358},{
            -134,-376},{12,-376}}, color={0,127,255}));
    connect(pipe39.port_b, pipe40.port_a) annotation (Line(points={{-138,-358},{-138,
            -372},{12,-372}}, color={0,127,255}));
    connect(pipe40.port_b, pipe41.port_a)
      annotation (Line(points={{32,-372},{144,-372}}, color={0,127,255}));
    connect(pipe40.port_a1, pipe41.port_b1)
      annotation (Line(points={{32,-376},{144,-376}}, color={0,127,255}));
    connect(F14oad.y[1], F14.Q) annotation (Line(points={{191,-328},{198,-328},
            {198,-312}},
                    color={0,0,127}));
    connect(F14.port_a, pipe42.port_b) annotation (Line(points={{208,-306},{208,
            -308},{230,-308},{230,-340}},
                         color={0,127,255}));
    connect(valveIncompressible23.port_b, pipe42.port_a1) annotation (Line(points={{210,
            -282},{234,-282},{234,-340}},      color={0,127,255}));
    connect(F14oad.u, realExpression26.y)
      annotation (Line(points={{168,-328},{159,-328}}, color={0,0,127}));
    connect(pipe41.port_a1, pipe42.port_b1) annotation (Line(points={{164,-376},{234,
            -376},{234,-360}}, color={0,127,255}));
    connect(pipe41.port_b, pipe42.port_a) annotation (Line(points={{164,-372},{230,
            -372},{230,-360}}, color={0,127,255}));
    connect(realExpression27.y, F15_load.u)
      annotation (Line(points={{149,-412},{158,-412}}, color={0,0,127}));
    connect(const24.y, valveIncompressible24.opening) annotation (Line(points={{176.7,
            -475},{192,-475},{192,-466}},              color={0,0,127}));
    connect(F15.port_a, pipe43.port_b) annotation (Line(points={{196,-432},{230,
            -432},{230,-422}},
                         color={0,127,255}));
    connect(valveIncompressible24.port_b, pipe43.port_a1) annotation (Line(points={{202,
            -458},{234,-458},{234,-422}},      color={0,127,255}));
    connect(pipe41.port_b, pipe43.port_a) annotation (Line(points={{164,-372},{230,
            -372},{230,-402}}, color={0,127,255}));
    connect(pipe41.port_a1, pipe43.port_b1) annotation (Line(points={{164,-376},{234,
            -376},{234,-402}}, color={0,127,255}));
    connect(pipe39.port_b, pipe44.port_a)
      annotation (Line(points={{-138,-358},{-138,-424}}, color={0,127,255}));
    connect(pipe39.port_a1, pipe44.port_b1)
      annotation (Line(points={{-134,-358},{-134,-424}}, color={0,127,255}));
    connect(realExpression28.y, F16_load.u)
      annotation (Line(points={{9,-448},{4,-448}},     color={0,0,127}));
    connect(const25.y, valveIncompressible25.opening) annotation (Line(points={{-12.7,
            -517},{-18,-517},{-18,-518},{-30,-518},{-30,-506}},
                                                       color={0,0,127}));
    connect(pipe45.port_b, F16.port_a)
      annotation (Line(points={{-86,-466},{-42,-466}}, color={0,127,255}));
    connect(F16_load.y[1], F16.Q) annotation (Line(points={{-19,-448},{-32,-448},
            {-32,-460}},color={0,0,127}));
    connect(valveIncompressible25.port_b, pipe45.port_a1) annotation (Line(points={{-40,
            -498},{-76,-498},{-76,-470},{-86,-470}},      color={0,127,255}));
    connect(pipe44.port_a1, pipe45.port_b1) annotation (Line(points={{-134,-444},{
            -134,-470},{-106,-470}}, color={0,127,255}));
    connect(pipe44.port_b, pipe45.port_a) annotation (Line(points={{-138,-444},{-138,
            -466},{-106,-466}}, color={0,127,255}));
    connect(F17.port_a, pipe46.port_b) annotation (Line(points={{-232,-496},{
            -218,-496},{-218,-474},{-204,-474}},
                                            color={0,127,255}));
    connect(valveIncompressible26.port_b, pipe46.port_a1)
      annotation (Line(points={{-234,-470},{-204,-470}}, color={0,127,255}));
    connect(const26.y, valveIncompressible26.opening) annotation (Line(points={{-249.3,
            -453},{-249.3,-454},{-244,-454},{-244,-462}}, color={0,0,127}));
    connect(realExpression29.y, F17_load.u)
      annotation (Line(points={{-265,-546},{-276,-546},{-276,-522},{-268,-522}},
                                                         color={0,0,127}));
    connect(F17_load.y[1], F17.Q) annotation (Line(points={{-245,-522},{-242,
            -522},{-242,-502}},
                          color={0,0,127}));
    connect(pipe46.port_b1, pipe45.port_b1)
      annotation (Line(points={{-184,-470},{-106,-470}}, color={0,127,255}));
    connect(pipe46.port_a, pipe45.port_a) annotation (Line(points={{-184,-474},{-138,
            -474},{-138,-466},{-106,-466}}, color={0,127,255}));
    connect(pipe.port_a1, pipe47.port_b1) annotation (Line(points={{-228,-36},{-216,
            -36},{-216,-140},{-250,-140}}, color={0,127,255}));
    connect(pipe.port_b, pipe47.port_a) annotation (Line(points={{-228,-32},{-220,
            -32},{-220,-136},{-250,-136}}, color={0,127,255}));
    connect(const27.y, valveIncompressible27.opening) annotation (Line(points={{-377.3,
            -377},{-360,-377},{-360,-366}}, color={0,0,127}));
    connect(F19_load.y[1], F19.Q) annotation (Line(points={{-383,-304},{-364,
            -304},{-364,-314}},
                          color={0,0,127}));
    connect(pipe47.port_b, F19.port_a) annotation (Line(points={{-270,-136},{
            -312,-136},{-312,-320},{-354,-320}},
                                            color={0,127,255}));
    connect(valveIncompressible27.port_b, pipe47.port_a1) annotation (Line(points={{-350,
            -358},{-308,-358},{-308,-140},{-270,-140}},       color={0,127,255}));
    connect(realExpression3.y, F19_load.u)
      annotation (Line(points={{-427,-304},{-406,-304}}, color={0,0,127}));
    connect(temperature8.port, pipe11.port_b) annotation (Line(points={{-154,
            212},{-154,204},{-144,204}},       color={0,127,255}));
    connect(pressure7.port, pipe11.port_b) annotation (Line(points={{-158,202},
            {-158,206},{-154,206},{-154,204},{-144,204}},
                                                    color={0,127,255}));
    connect(pressure13.port, pipe19.port_b) annotation (Line(points={{328,204},
            {328,206},{340,206}},
                             color={0,127,255}));
    connect(temperature14.port, pipe19.port_b) annotation (Line(points={{332,212},
            {332,206},{340,206}}, color={0,127,255}));
    connect(temperature12.port, pipe15.port_b) annotation (Line(points={{104,214},
            {104,212},{112,212},{112,208}},
                                        color={0,127,255}));
    connect(pressure11.port, pipe15.port_b) annotation (Line(points={{100,206},
            {100,212},{112,212},{112,208}},
                                     color={0,127,255}));
    connect(temperature11.port, pipe14.port_b) annotation (Line(points={{24,214},
            {24,212},{34,212},{34,208}},
                                     color={0,127,255}));
    connect(pressure10.port, temperature11.port) annotation (Line(points={{20,206},
            {20,212},{24,212},{24,214}},
                                      color={0,127,255}));
    connect(temperature10.port, pipe12.port_b) annotation (Line(points={{-66,212},
            {-66,210},{-62,210},{-62,204}}, color={0,127,255}));
    connect(pressure9.port, pipe12.port_b) annotation (Line(points={{-74,204},{
            -74,210},{-62,210},{-62,204}},
                                       color={0,127,255}));
    connect(valveIncompressible3.port_b, volumeFlowRate3.port_a) annotation (Line(
          points={{-156,268},{-130,268},{-130,264}}, color={0,127,255}));
    connect(volumeFlowRate3.port_b, pipe11.port_a1) annotation (Line(points={{-130,
            244},{-130,224},{-140,224},{-140,204}}, color={0,127,255}));
    connect(valveIncompressible5.port_b, volumeFlowRate4.port_a) annotation (Line(
          points={{-68,276},{-46,276},{-46,266}}, color={0,127,255}));
    connect(volumeFlowRate4.port_b, pipe12.port_a1) annotation (Line(points={{-46,246},
            {-46,226},{-58,226},{-58,204}},      color={0,127,255}));
    connect(valveIncompressible6.port_b, volumeFlowRate5.port_a)
      annotation (Line(points={{22,272},{46,272},{46,268}},color={0,127,255}));
    connect(volumeFlowRate5.port_b, pipe14.port_a1)
      annotation (Line(points={{46,248},{46,228},{38,228},{38,208}},
                                                   color={0,127,255}));
    connect(valveIncompressible7.port_b, volumeFlowRate6.port_a) annotation (
        Line(points={{106,280},{128,280},{128,274}},
                                                  color={0,127,255}));
    connect(volumeFlowRate6.port_b, pipe15.port_a1) annotation (Line(points={{128,254},
            {128,246},{116,246},{116,208}},      color={0,127,255}));
    connect(valveIncompressible9.port_b, volumeFlowRate8.port_a) annotation (
        Line(points={{334,278},{356,278},{356,274}}, color={0,127,255}));
    connect(volumeFlowRate8.port_b, pipe19.port_a1) annotation (Line(points={{356,254},
            {354,254},{354,206},{344,206}},          color={0,127,255}));
    connect(pressure14.port, volumeFlowRate3.port_a) annotation (Line(points={{-132,
            274},{-132,264},{-130,264}},                 color={0,127,255}));
    connect(temperature15.port, volumeFlowRate3.port_a) annotation (Line(points={{-150,
            272},{-150,268},{-130,268},{-130,264}},       color={0,127,255}));
    connect(temperature20.port, volumeFlowRate8.port_a) annotation (Line(points={{338,288},
            {338,278},{356,278},{356,274}},           color={0,127,255}));
    connect(pressure19.port, volumeFlowRate8.port_a)
      annotation (Line(points={{356,290},{356,274}}, color={0,127,255}));
    connect(temperature18.port, volumeFlowRate6.port_a) annotation (Line(points={{110,286},
            {110,280},{128,280},{128,274}},       color={0,127,255}));
    connect(pressure17.port, volumeFlowRate6.port_a)
      annotation (Line(points={{128,288},{128,274}},
                                                   color={0,127,255}));
    connect(temperature17.port, volumeFlowRate5.port_a) annotation (Line(points={{24,278},
            {24,272},{46,272},{46,268}},        color={0,127,255}));
    connect(pressure16.port, volumeFlowRate5.port_a) annotation (Line(points={{42,280},
            {42,272},{46,272},{46,268}},         color={0,127,255}));
    connect(pressure15.port, volumeFlowRate4.port_a)
      annotation (Line(points={{-46,284},{-46,266}}, color={0,127,255}));
    connect(temperature16.port, volumeFlowRate4.port_a) annotation (Line(points={{-64,282},
            {-64,276},{-46,276},{-46,266}},           color={0,127,255}));
    connect(temperature9.port, valveIncompressible2.port_b) annotation (Line(
          points={{-116,64},{-116,66},{-74,66}},           color={0,127,255}));
    connect(pressure8.port, valveIncompressible2.port_b) annotation (Line(
          points={{-92,62},{-92,66},{-74,66}}, color={0,127,255}));
    connect(F6.port_b, volumeFlowRate9.port_a) annotation (Line(points={{-36,96},
            {-36,90},{-26,90}}, color={0,127,255}));
    connect(volumeFlowRate9.port_b, valveIncompressible2.port_a) annotation (
        Line(points={{-26,70},{-24,70},{-24,66},{-54,66}}, color={0,127,255}));
    connect(F7.port_b, volumeFlowRate10.port_a) annotation (Line(points={{240,124},
            {264,124},{264,114}},      color={0,127,255}));
    connect(volumeFlowRate10.port_b, valveIncompressible10.port_a) annotation (
        Line(points={{264,94},{242,94}},          color={0,127,255}));
    connect(pressure20.port, pipe9.port_b) annotation (Line(points={{-68,106},{
            -68,96},{-96,96}}, color={0,127,255}));
    connect(temperature21.port, pipe9.port_b) annotation (Line(points={{-86,112},
            {-86,96},{-96,96}}, color={0,127,255}));
    connect(F8.port_b, volumeFlowRate11.port_a) annotation (Line(points={{-52,
            -2},{-20,-2},{-20,-8}}, color={0,127,255}));
    connect(volumeFlowRate11.port_b, valveIncompressible4.port_a) annotation (
        Line(points={{-20,-28},{-20,-36},{-50,-36}}, color={0,127,255}));
    connect(pressure21.port, valveIncompressible4.port_b) annotation (Line(
          points={{-82,-42},{-82,-36},{-70,-36}}, color={0,127,255}));
    connect(temperature22.port, valveIncompressible4.port_b) annotation (Line(
          points={{-104,-46},{-106,-46},{-106,-36},{-70,-36}}, color={0,127,255}));
    connect(temperature23.port, valveIncompressible1.port_b) annotation (Line(
          points={{-194,90},{-194,70},{-198,70}}, color={0,127,255}));
    connect(temperature24.port, F5.port_a) annotation (Line(points={{-192,36},{
            -192,48},{-194,48}}, color={0,127,255}));
    connect(pressure23.port, pipe7.port_b) annotation (Line(points={{-168,34},{
            -168,40},{-184,40},{-184,48},{-180,48}}, color={0,127,255}));
    connect(pressure24.port, F8.port_a)
      annotation (Line(points={{-78,6},{-78,-2},{-72,-2}}, color={0,127,255}));
    connect(temperature25.port, F8.port_a) annotation (Line(points={{-98,6},{
            -98,4},{-88,4},{-88,-2},{-72,-2}}, color={0,127,255}));
    connect(pressure25.port, F10.port_a) annotation (Line(points={{-70,-102},{
            -70,-108},{-68,-108}}, color={0,127,255}));
    connect(temperature26.port, pipe31.port_b)
      annotation (Line(points={{-88,-102},{-88,-108}}, color={0,127,255}));
    connect(pressure26.port, valveIncompressible17.port_b) annotation (Line(
          points={{-92,-136},{-92,-132},{-82,-132},{-82,-138},{-66,-138}},
          color={0,127,255}));
    connect(temperature27.port, valveIncompressible17.port_b) annotation (Line(
          points={{-114,-140},{-114,-132},{-82,-132},{-82,-138},{-66,-138}},
          color={0,127,255}));
    connect(pressure27.port, pipe35.port_a1) annotation (Line(points={{-88,-264},
            {-88,-262},{-66,-262},{-66,-234},{-84,-234}}, color={0,127,255}));
    connect(temperature28.port, pipe35.port_a1) annotation (Line(points={{-110,
            -268},{-110,-262},{-66,-262},{-66,-234},{-84,-234}}, color={0,127,
            255}));
    connect(pressure28.port, pipe33.port_a1) annotation (Line(points={{102,-192},
            {102,-186},{-34,-186}},                       color={0,127,255}));
    connect(temperature29.port, pipe33.port_a1) annotation (Line(points={{122,
            -192},{120,-192},{120,-186},{-34,-186}},           color={0,127,255}));
    connect(pressure29.port, F12_2.port_a) annotation (Line(points={{28,-302},{
            28,-294},{56,-294}}, color={0,127,255}));
    connect(temperature30.port, F12_2.port_a) annotation (Line(points={{6,-306},
            {6,-294},{56,-294}}, color={0,127,255}));
    connect(temperature31.port, pipe40.port_a1) annotation (Line(points={{52,
            -338},{52,-326},{44,-326},{44,-376},{32,-376}}, color={0,127,255}));
    connect(pressure30.port, pipe40.port_a1) annotation (Line(points={{74,-334},
            {74,-326},{44,-326},{44,-376},{32,-376}}, color={0,127,255}));
    connect(pressure31.port, pipe42.port_b) annotation (Line(points={{220,-332},
            {220,-328},{230,-328},{230,-340}}, color={0,127,255}));
    connect(temperature32.port, pipe42.port_b) annotation (Line(points={{202,
            -340},{202,-328},{230,-328},{230,-340}}, color={0,127,255}));
    connect(temperature33.port, pipe42.port_a1) annotation (Line(points={{250,
            -288},{250,-282},{234,-282},{234,-340}}, color={0,127,255}));
    connect(pressure32.port, pipe42.port_a1) annotation (Line(points={{272,-284},
            {272,-282},{234,-282},{234,-340}}, color={0,127,255}));
    connect(const23.y, valveIncompressible23.opening) annotation (Line(points={
            {180.7,-267},{200,-267},{200,-274}}, color={0,0,127}));
    connect(F12_2_load.y[1], F12_2.Q) annotation (Line(points={{71,-278},{66,
            -278},{66,-288}}, color={0,0,127}));
    connect(F15_load.y[1], F15.Q) annotation (Line(points={{181,-412},{186,-412},
            {186,-426}}, color={0,0,127}));
    connect(temperature34.port, pipe43.port_a1) annotation (Line(points={{216,
            -474},{216,-458},{234,-458},{234,-422}}, color={0,127,255}));
    connect(pressure33.port, pipe43.port_a1)
      annotation (Line(points={{234,-466},{234,-422}}, color={0,127,255}));
    connect(pressure34.port, pipe43.port_b) annotation (Line(points={{218,-410},
            {218,-432},{230,-432},{230,-422}}, color={0,127,255}));
    connect(temperature35.port, pipe43.port_b) annotation (Line(points={{196,
            -414},{196,-424},{204,-424},{204,-432},{230,-432},{230,-422}},
          color={0,127,255}));
    connect(temperature36.port, F16.port_a) annotation (Line(points={{-78,-454},
            {-78,-466},{-42,-466}}, color={0,127,255}));
    connect(pressure35.port, F16.port_a) annotation (Line(points={{-52,-456},{
            -52,-466},{-42,-466}}, color={0,127,255}));
    connect(pressure36.port, pipe45.port_a1) annotation (Line(points={{-50,-506},
            {-50,-498},{-76,-498},{-76,-470},{-86,-470}}, color={0,127,255}));
    connect(temperature37.port, pipe45.port_a1) annotation (Line(points={{-76,
            -510},{-76,-470},{-86,-470}}, color={0,127,255}));
    connect(pressure37.port, F12.port_a) annotation (Line(points={{-64,-218},{
            -64,-230},{-58,-230}}, color={0,127,255}));
    connect(temperature38.port, pipe35.port_b)
      annotation (Line(points={{-84,-216},{-84,-230}}, color={0,127,255}));
    connect(pressure38.port, F13.port_a) annotation (Line(points={{138,-174},{
            138,-182},{148,-182}}, color={0,127,255}));
    connect(temperature39.port, F13.port_a) annotation (Line(points={{118,-172},
            {118,-182},{148,-182}}, color={0,127,255}));
    connect(temperature40.port, pipe46.port_b) annotation (Line(points={{-218,
            -506},{-218,-474},{-204,-474}}, color={0,127,255}));
    connect(pressure39.port, pipe46.port_b) annotation (Line(points={{-192,-502},
            {-192,-496},{-218,-496},{-218,-474},{-204,-474}}, color={0,127,255}));
    connect(temperature41.port, valveIncompressible26.port_b) annotation (Line(
          points={{-232,-452},{-232,-470},{-234,-470}}, color={0,127,255}));
    connect(pressure40.port, pipe46.port_a1) annotation (Line(points={{-208,
            -454},{-208,-470},{-204,-470}}, color={0,127,255}));
    connect(temperature42.port, valveIncompressible20.port_b) annotation (Line(
          points={{-216,-218},{-216,-234},{-220,-234}}, color={0,127,255}));
    connect(pressure41.port, pipe37.port_a1) annotation (Line(points={{-196,
            -230},{-196,-234},{-194,-234}}, color={0,127,255}));
    connect(temperature43.port, pipe37.port_b) annotation (Line(points={{-208,
            -264},{-208,-238},{-194,-238}}, color={0,127,255}));
    connect(pressure42.port, pipe37.port_b) annotation (Line(points={{-186,-260},
            {-186,-258},{-208,-258},{-208,-238},{-194,-238}}, color={0,127,255}));
    connect(temperature44.port, pipe38.port_a1) annotation (Line(points={{-224,
            -316},{-224,-320},{-190,-320}}, color={0,127,255}));
    connect(pressure43.port, pipe38.port_a1) annotation (Line(points={{-202,
            -318},{-202,-320},{-190,-320}}, color={0,127,255}));
    connect(temperature45.port, pipe38.port_b) annotation (Line(points={{-222,
            -356},{-222,-346},{-200,-346},{-200,-324},{-190,-324}}, color={0,
            127,255}));
    connect(pressure44.port, pipe38.port_b) annotation (Line(points={{-196,-352},
            {-196,-346},{-200,-346},{-200,-324},{-190,-324}}, color={0,127,255}));
    connect(temperature46.port, pipe47.port_a1) annotation (Line(points={{-336,
            -372},{-336,-358},{-308,-358},{-308,-140},{-270,-140}}, color={0,
            127,255}));
    connect(pressure45.port, pipe47.port_a1) annotation (Line(points={{-310,
            -368},{-310,-358},{-308,-358},{-308,-140},{-270,-140}}, color={0,
            127,255}));
    connect(temperature47.port, F19.port_a) annotation (Line(points={{-350,-310},
            {-350,-320},{-354,-320}}, color={0,127,255}));
    connect(pressure46.port, F19.port_a) annotation (Line(points={{-328,-314},{
            -328,-320},{-354,-320}}, color={0,127,255}));
    connect(F2_2oad.y[1], F2.Q) annotation (Line(points={{201,238},{208,238},{
            208,250}}, color={0,0,127}));
    connect(const11.y, valveIncompressible11.opening) annotation (Line(points={{200.7,
            297},{206,297},{206,288},{214,288}},        color={0,0,127}));
    connect(F2_2oad.u, realExpression14.y) annotation (Line(points={{178,238},{
            167,238},{167,210}}, color={0,0,127}));
    connect(valveIncompressible11.port_a, F2.port_b) annotation (Line(points={{204,280},
            {198,280},{198,256}},                    color={0,127,255}));
    connect(valveIncompressible11.port_b, volumeFlowRate12.port_a) annotation (
        Line(points={{224,280},{224,276},{246,276}}, color={0,127,255}));
    connect(volumeFlowRate12.port_b, pipe48.port_a1) annotation (Line(points={{246,256},
            {246,208},{234,208}},          color={0,127,255}));
    connect(temperature49.port, volumeFlowRate12.port_a) annotation (Line(
          points={{228,290},{228,276},{246,276}}, color={0,127,255}));
    connect(pressure48.port, volumeFlowRate12.port_a)
      annotation (Line(points={{246,292},{246,276}}, color={0,127,255}));
    connect(pipe48.port_b1, pipe16.port_a1) annotation (Line(points={{234,188},
            {234,174},{148,174}}, color={0,127,255}));
    connect(pipe48.port_a, pipe18.port_a) annotation (Line(points={{230,188},{
            230,178},{260,178}}, color={0,127,255}));
    connect(pipe4.port_a1, pipe6.port_b1) annotation (Line(points={{-134,-12},{
            -132,-12},{-132,-6},{-112,-6}}, color={0,127,255}));
    connect(mflow.y[1], pump.m_flow_set) annotation (Line(points={{-353,2},{
            -383,2},{-383,-23.8}}, color={0,0,127}));
    connect(temperature2.port, valveIncompressible10.port_b) annotation (Line(
          points={{198,106},{212,106},{212,94},{222,94}}, color={0,127,255}));
    connect(pressure1.port, valveIncompressible10.port_b) annotation (Line(
          points={{194,88},{202,88},{202,106},{212,106},{212,94},{222,94}},
          color={0,127,255}));
    connect(temperature3.port, valveIncompressible12.port_b) annotation (Line(
          points={{274,32},{280,32},{280,26},{290,26}}, color={0,127,255}));
    connect(pressure2.port, valveIncompressible12.port_b) annotation (Line(
          points={{268,14},{274,14},{274,26},{290,26}}, color={0,127,255}));
    connect(temperature4.port, pipe25.port_a1) annotation (Line(points={{220,
            -34},{220,-22},{224,-22},{224,14}}, color={0,127,255}));
    connect(pressure3.port, pipe25.port_a1) annotation (Line(points={{232,-14},
            {224,-14},{224,14}}, color={0,127,255}));
    connect(pressure4.port, boundary1.ports[3]) annotation (Line(points={{-292,
            -64},{-292,-70},{-326.667,-70}}, color={0,127,255}));
    connect(F10.port_b, volumeFlowRate1.port_a) annotation (Line(points={{-48,
            -108},{-12,-108},{-12,-116},{-14,-116}}, color={0,127,255}));
    connect(valveIncompressible17.port_a, volumeFlowRate1.port_b) annotation (
        Line(points={{-46,-138},{-14,-138},{-14,-136}}, color={0,127,255}));
    connect(F5.port_b, volumeFlowRate2.port_a) annotation (Line(points={{-214,
            48},{-214,52},{-238,52}}, color={0,127,255}));
    connect(volumeFlowRate2.port_b, valveIncompressible1.port_a) annotation (
        Line(points={{-258,52},{-270,52},{-270,70},{-218,70}}, color={0,127,255}));
    connect(F9_1.port_b, volumeFlowRate7.port_a)
      annotation (Line(points={{170,4},{170,0},{164,0}}, color={0,127,255}));
    connect(volumeFlowRate7.port_b, valveIncompressible13.port_a) annotation (
        Line(points={{164,-20},{164,-22},{188,-22}}, color={0,127,255}));
    connect(F9_2.port_b, volumeFlowRate13.port_a) annotation (Line(points={{320,52},
            {320,48},{328,48}},     color={0,127,255}));
    connect(volumeFlowRate13.port_b, valveIncompressible12.port_a) annotation (
        Line(points={{328,28},{319,28},{319,26},{310,26}}, color={0,127,255}));
    connect(pump.port_b, volumeFlowRate14.port_a)
      annotation (Line(points={{-368,-32},{-334,-32}}, color={0,127,255}));
    connect(volumeFlowRate14.port_b, pipe.port_a)
      annotation (Line(points={{-314,-32},{-248,-32}}, color={0,127,255}));
    connect(pressure.port, pipe.port_a) annotation (Line(points={{-256,-20},{
            -256,-32},{-248,-32}}, color={0,127,255}));
    connect(F11.port_b, volumeFlowRate15.port_a) annotation (Line(points={{-238,
            -258},{-250,-258},{-250,-256},{-262,-256}}, color={0,127,255}));
    connect(volumeFlowRate15.port_b, valveIncompressible20.port_a) annotation (
        Line(points={{-262,-236},{-262,-234},{-240,-234}}, color={0,127,255}));
    connect(F12.port_b, volumeFlowRate16.port_a) annotation (Line(points={{-38,
            -230},{-22,-230},{-22,-236}}, color={0,127,255}));
    connect(volumeFlowRate16.port_b, valveIncompressible19.port_a) annotation (
        Line(points={{-22,-256},{-22,-262},{-40,-262}}, color={0,127,255}));
    connect(F13.port_b, volumeFlowRate17.port_a) annotation (Line(points={{168,
            -182},{168,-188},{196,-188}}, color={0,127,255}));
    connect(volumeFlowRate17.port_b, valveIncompressible18.port_a) annotation (
        Line(points={{196,-208},{196,-212},{170,-212}}, color={0,127,255}));
    connect(F14.port_b, volumeFlowRate18.port_a) annotation (Line(points={{188,
            -306},{176,-306},{176,-304},{164,-304}}, color={0,127,255}));
    connect(volumeFlowRate18.port_b, valveIncompressible23.port_a) annotation (
        Line(points={{164,-284},{164,-282},{190,-282}}, color={0,127,255}));
    connect(F12_2.port_b, volumeFlowRate19.port_a) annotation (Line(points={{76,
            -294},{76,-298},{110,-298}}, color={0,127,255}));
    connect(volumeFlowRate19.port_b, valveIncompressible22.port_a) annotation (
        Line(points={{110,-318},{104,-318},{104,-326},{100,-326}}, color={0,127,
            255}));
    connect(F19.port_b, volumeFlowRate20.port_a) annotation (Line(points={{-374,
            -320},{-398,-320},{-398,-328}}, color={0,127,255}));
    connect(volumeFlowRate20.port_b, valveIncompressible27.port_a) annotation (
        Line(points={{-398,-348},{-398,-358},{-370,-358}}, color={0,127,255}));
    connect(F17.port_b, volumeFlowRate21.port_a) annotation (Line(points={{-252,
            -496},{-252,-494},{-278,-494}}, color={0,127,255}));
    connect(volumeFlowRate21.port_b, valveIncompressible26.port_a) annotation (
        Line(points={{-278,-474},{-278,-470},{-254,-470}}, color={0,127,255}));
    connect(F16.port_b, volumeFlowRate22.port_a) annotation (Line(points={{-22,
            -466},{-20,-466},{-20,-470},{1.77636e-15,-470}}, color={0,127,255}));
    connect(volumeFlowRate22.port_b, valveIncompressible25.port_a) annotation (
        Line(points={{-1.83187e-15,-490},{-8,-490},{-8,-498},{-20,-498}}, color
          ={0,127,255}));
    connect(F15.port_b, volumeFlowRate23.port_a) annotation (Line(points={{176,
            -432},{162,-432},{162,-434},{148,-434}}, color={0,127,255}));
    connect(volumeFlowRate23.port_b, valveIncompressible24.port_a) annotation (
        Line(points={{148,-454},{148,-458},{182,-458}}, color={0,127,255}));
    connect(F18.port_b, volumeFlowRate24.port_a)
      annotation (Line(points={{-254,-346},{-278,-346}}, color={0,127,255}));
    connect(volumeFlowRate24.port_b, valveIncompressible21.port_a) annotation (
        Line(points={{-278,-326},{-278,-320},{-252,-320}}, color={0,127,255}));
    connect(temperature5.port, F7.port_b) annotation (Line(points={{252,132},{
            252,124},{240,124}}, color={0,127,255}));
    connect(pressure5.port, temperature5.port) annotation (Line(points={{264,
            130},{258,130},{258,132},{252,132}}, color={0,127,255}));
    connect(pipe48.port_b, F2.port_a) annotation (Line(points={{230,208},{230,
            256},{218,256}}, color={0,127,255}));
    connect(temperature48.port, F2.port_a) annotation (Line(points={{224,216},{
            230,216},{230,256},{218,256}}, color={0,127,255}));
    connect(pressure47.port, temperature48.port) annotation (Line(points={{216,
            214},{220,214},{220,216},{224,216}}, color={0,127,255}));
    connect(temperature6.port, pipe25.port_b) annotation (Line(points={{210,18},
            {212,18},{212,4},{220,4},{220,14}}, color={0,127,255}));
    connect(pressure6.port, pipe25.port_b) annotation (Line(points={{196,16},{
            196,10},{212,10},{212,4},{220,4},{220,14}}, color={0,127,255}));
    connect(temperature7.port, F9_2.port_a) annotation (Line(points={{276,62},{
            282,62},{282,52},{300,52}}, color={0,127,255}));
    connect(pressure12.port, F9_2.port_a) annotation (Line(points={{292,62},{
            288,62},{288,58},{282,58},{282,52},{300,52}}, color={0,127,255}));
    connect(pressure22.port, valveIncompressible1.port_b) annotation (Line(
          points={{-172,90},{-184,90},{-184,80},{-194,80},{-194,70},{-198,70}},
          color={0,127,255}));
    annotation (
      Icon(coordinateSystem(preserveAspectRatio=false, extent={{-500,-540},{380,320}}),
                      graphics={
          Ellipse(lineColor = {75,138,73},
                  fillColor={255,255,255},
                  fillPattern = FillPattern.Solid,
                  extent={{-100,-100},{100,100}}),
          Polygon(lineColor = {0,0,255},
                  fillColor = {75,138,73},
                  pattern = LinePattern.None,
                  fillPattern = FillPattern.Solid,
                  points={{-36,60},{64,0},{-36,-60},{-36,60}})}),
      Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-500,-540},{380,
              320}}), graphics={Rectangle(
            extent={{-492,36},{-276,-114}},
            lineColor={238,46,47},
            lineThickness=0.5,
            pattern=LinePattern.Dash), Text(
            extent={{-452,78},{-392,48}},
            textColor={238,46,47},
            textString="热源")}),
      experiment(
        StopTime=345600,
        Interval=3600,
        __Dymola_Algorithm="Dassl"));
  end HeatingNetWork_Case01;

  model HeatingNetWork_Case02 "供热管网"
    Modelica.Fluid.Machines.ControlledPump pump(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      p_b_start=400000,
      m_flow_start=44,
      N_nominal(displayUnit="rpm"),
      T_start=313.15,
      p_a_nominal=300000,
      p_b_nominal=600000,
      m_flow_nominal=400/3600*1000,
      use_m_flow_set=false)
                           "循环泵"
      annotation (Placement(transformation(extent={{-390,-42},{-370,-22}})));
    Pipe pipe(
      Length=8.39, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-248,-44},{-228,-24}})));
    Modelica.Fluid.Sources.Boundary_pT boundary(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      use_p_in=false,
      use_T_in=true,
      p=300000,
      T=323.15,
      nPorts=2) "供水边界"
      annotation (Placement(transformation(extent={{-436,-22},{-416,-42}})));
    Modelica.Fluid.Sources.Boundary_pT boundary1(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      use_p_in=false,
      use_T_in=false,
      p=200000,
      nPorts=2) annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=-90,
          origin={-328,-80})));
    Modelica.Fluid.Sensors.Pressure pressure(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-268,-28},{-248,-8}})));
    Modelica.Blocks.Sources.RealExpression realExpression15(y=time/3600)
      annotation (Placement(transformation(extent={{-326,-8},{-346,12}})));
    Modelica.Blocks.Tables.CombiTable1Ds mflow(table=[0,44.46389092; 1,
          40.35833147; 2,43.53333367; 3,39.61111281; 4,36.92222171; 5,
          39.45277744; 6,44.48888991; 7,39.11111196; 8,42.03888787; 9,
          41.92777846; 10,44.60833232; 11,44.17222341; 12,37.83888923; 13,
          41.36944241; 14,43.65555657; 15,38.50277795; 16,39.19444614; 17,
          42.28889041; 18,40.89166853; 19,40.10277642; 20,43.45277574; 21,
          40.68055471; 22,38.08055454; 23,38.85000017; 24,40.99444495; 25,
          37.45833503; 26,42.64444563; 27,36.18055556; 28,41.23333401; 29,
          40.81388685; 30,39.64722104; 31,37.67222087; 32,38.00000085; 33,
          41.49722205; 34,42.46111128; 35,40.08889092; 36,38.57499864; 37,
          40.77222188; 38,42.94166565; 39,40.36388821; 40,46.04999966; 41,
          42.57777744; 42,36.4444436; 43,39.81111315; 44,44.29999881; 45,
          40.46111213; 46,37.26666768; 47,42.98888736; 48,40.8749983; 49,
          43.29444461; 50,38.89444563; 51,42.79166751; 52,38.47777896; 53,
          39.78055742; 54,40.82222409; 55,40.3166665; 56,37.58055369; 57,
          43.11944326; 58,41.26666599; 59,44.10833147; 60,39.75277795; 61,
          39.64722104; 62,38.23610942; 63,41.11944411; 64,38.3111106; 65,
          41.8027793; 66,43.20000119; 67,40.35555522; 68,39.94444529; 69,
          41.67222341; 70,39.47500017; 71,39.98055352; 72,40.90000153; 73,
          41.21666802; 74,38.10277727; 75,45.39722019; 76,39.1805564; 77,
          42.59166718; 78,44.01666853; 79,37.86944495; 80,39.80277591; 81,
          38.24444241; 82,37.63888889; 83,38.77499898; 84,40.40833367; 85,
          38.61388736; 86,42.27777693; 87,44.75277795; 88,40.15277863; 89,
          48.33889008; 90,36.3222207; 91,39.29999881; 92,38.90277863; 93,
          42.58333418; 94,44.42499797; 95,40.12777964; 96,37.15555403; 97,
          36.34722392; 98,37.8750017; 99,35.60833401; 100,42.20833249; 101,
          40.17777761; 102,39.49166616; 103,38.69444529; 104,40.95277574; 105,
          40.11666616; 106,40.73610942; 107,41.01666768; 108,45.98333147; 109,
          40.64722273; 110,41.29999797; 111,45.01110925; 112,43.77777947; 113,
          39.12777795; 114,43.97499932; 115,35.91111077; 116,39.21388838; 117,
          40.9416665; 118,42.88333469; 119,37.36111111; 120,42.7444458; 121,
          43.41388702; 122,37.58055369; 123,41.41944461; 124,38.17222171; 125,
          45.85833232; 126,41.6250017; 127,41.52222104; 128,41.01388719; 129,
          39.76388719; 130,41.71666463; 131,45.66111247; 132,41.36388991; 133,
          44.45000119; 134,40.56944529; 135,40.67222171; 136,43.35833232; 137,
          42.86111196; 138,45.17500136; 139,43.35555606; 140,41.40833537; 141,
          42.54444546; 142,42.2555542; 143,42.01666514; 144,37.32499864; 145,
          33.1583341; 146,41.27777947; 147,41.34444343; 148,36.80833181; 149,
          35.23611069; 150,39.21388838; 151,42.70555708; 152,40.12499915; 153,
          45.58611128; 154,44.79166667; 155,41.78055657; 156,36.59999847; 157,
          39.79166667; 158,36.77499983; 159,41.16944631; 160,43.6277771; 161,
          44.05000051; 162,39.45555369; 163,41.87777625; 164,36.74722036; 165,
          39.67777676; 166,41.80555556; 167,37.97500186; 168,40.26111179; 169,
          36.72222137; 170,36.71111213; 171,37.10833232; 172,41.48611281; 173,
          41.37777964; 174,39.8777771; 175,41.89444648; 176,41.79999881; 177,
          43.00000085; 178,37.82222324; 179,40.80833435; 180,36.55000051; 181,
          45.16666836; 182,39.70555623; 183,39.73333147; 184,41.86111026; 185,
          39.46389092; 186,41.23055352; 187,39.21388838; 188,42.70555708; 189,
          40.89166853; 190,40.04999797; 191,39.36111026; 192,36.83055454; 193,
          41.05277591; 194,38.46944173; 195,37.69721985; 196,41.98333316; 197,
          40.86944156; 198,42.92777591; 199,38.80833096; 200,45.71666718; 201,
          40.76944563; 202,35.41666667; 203,41.52499729; 204,41.96111043; 205,
          40.04444546; 206,37.10555606; 207,40.82500034; 208,42.43055556; 209,
          37.29999966; 210,39.45277744; 211,41.49444156; 212,40.4444419; 213,
          41.83888753; 214,40.1277754; 215,41.55277676; 216,41.25555556; 217,
          40.48333056; 218,39.41388889; 219,40.40277778; 220,38.78610833; 221,
          38.04444167; 222,39.275; 223,40.15555556; 224,39.91944167; 225,
          42.24999722; 226,39.675; 227,40.17499722; 228,40.98055556; 229,
          37.87499722; 230,41.20277778; 231,35.57222222; 232,36.58888889; 233,
          44.38610833; 234,43.66944167; 235,38.26110833; 236,40.41388611; 237,
          43.21666667; 238,36.06944167; 239,36.19722222; 240,41.80833056; 241,
          38.40277778; 242,43.29444444; 243,38.36944167; 244,39.91944167; 245,
          39.74722222; 246,43.07777778; 247,38.93611111; 248,38.17222222; 249,
          40.58333056; 250,40.56111111; 251,42.95833056; 252,36.53055278; 253,
          36.49444167; 254,36.477775; 255,41.79166667; 256,40.73888889; 257,
          40.30833333; 258,38.84721944; 259,39.61944167; 260,44.77777778; 261,
          42.00555556; 262,45.47777778; 263,47.09444167; 264,38.64166667; 265,
          42.44444444; 266,47.33333056; 267,38.18333056; 268,41.60555556; 269,
          39.24721944; 270,39.48055278; 271,37.08888889; 272,44.02777778; 273,
          37.46111111; 274,43.66666667; 275,41.30555556; 276,42.56111111; 277,
          45.76944167; 278,39.24166667; 279,39.85833056; 280,38.975; 281,38.975;
          282,39.55277778; 283,39.46388611; 284,38.78333333; 285,37.54444444;
          286,43.27499722; 287,39.14444444; 288,39.04444444; 289,39.56666667;
          290,38.36110833; 291,40.225; 292,40.64166667; 293,44.69722222; 294,
          39.575; 295,43.61111111; 296,48.31111111; 297,35.97499722; 298,
          41.08333056; 299,41.00833056; 300,42.202775; 301,44.202775; 302,
          40.26388889; 303,43.41111111; 304,38.70277778; 305,39.08333333; 306,
          40.36666389; 307,40.58611111; 308,43.32777778; 309,37.99444444; 310,
          41.71388889; 311,36.80555556; 312,40.44722222; 313,42.78333056; 314,
          41.29166389; 315,38.15555556; 316,38.59166389; 317,44.21111111; 318,
          40.70833333; 319,37.01110833; 320,37.50555556; 321,41.43055278; 322,
          38.79444444; 323,40.84722222; 324,42.17221944; 325,39.51388889; 326,
          43.71666389; 327,41.18611111; 328,39.25833333; 329,41.91110833; 330,
          40.58055556; 331,43.06944444; 332,39.87221944; 333,39.69444167; 334,
          39.67221944; 335,41.53888611; 336,43.41111111; 337,38.90833056; 338,
          37.12499722; 339,38.87222222; 340,39.67221944; 341,43.55; 342,
          41.84166389; 343,38.36944167; 344,40.58055556; 345,42.90277778; 346,
          42.64999722; 347,40.93055278; 348,36.78610833; 349,43.99444167; 350,
          40.16111111; 351,42.80833333; 352,41.275; 353,42.53333333; 354,
          38.30277778; 355,40.57777778; 356,39.602775; 357,46.04166667; 358,
          38.96944167; 359,41.125; 360,39.61666667; 361,46.01111111; 362,40.025;
          363,39.402775; 364,39.43888889; 365,37.31388889; 366,38.71388889; 367,
          40.87499722; 368,39.46666667; 369,42.00555556; 370,41.26666667; 371,
          43.90277778; 372,37.04999722; 373,42.16388611; 374,41.40555556; 375,
          36.07222222; 376,38.28055556; 377,41.64444444; 378,38.22777778; 379,
          40.45555556; 380,37.57777778; 381,44.10555556; 382,41.48333333; 383,
          41.802775; 384,42.55277778; 385,42.31944167; 386,43.92499722; 387,
          41.21388889; 388,43.43333333; 389,43.71944444; 390,41.93333056; 391,
          40.925; 392,38.06388889; 393,39.66944444; 394,39.98055278; 395,
          42.34722222; 396,39.75277778; 397,43.677775; 398,38.24444167; 399,
          42.57777778; 400,39.15555278; 401,36.65833333; 402,35.275; 403,
          42.80277778; 404,41.51111111; 405,41.59166667; 406,43.50833056; 407,
          35.35277778; 408,41.01666667; 409,38.53611111; 410,40.68055556; 411,
          45.11388889; 412,44.22777778; 413,41.60555556; 414,41.13611111; 415,
          42.29444167; 416,41.19166389; 417,43.29722222; 418,42.30833333; 419,
          41.44166667; 420,40.48333056; 421,44.78888611; 422,42.30555556; 423,
          40.79999722; 424,39.67777778; 425,40.65; 426,38.44444167; 427,
          40.17499722; 428,41.83333056; 429,40.46666389; 430,42.63610833; 431,
          40.77499722; 432,44.65555278; 433,42.91111111; 434,43.92777778; 435,
          44.44166389; 436,42.24722222; 437,42.69166667; 438,45.93611111; 439,
          36.26110833; 440,45.39444444; 441,44.02777778; 442,41.66111111; 443,
          42.47777778; 444,43.33610833; 445,40.01944167; 446,41.85833333; 447,
          63.10555278; 448,55.99444444; 449,57.96666389; 450,58.35833333; 451,
          60.025; 452,60.127775; 453,56.18610833; 454,60.85833333; 455,
          59.26388611; 456,44.65555278; 457,42.91111111; 458,43.92777778; 459,
          44.44166389; 460,42.24722222; 461,42.69166667; 462,45.93611111; 463,
          36.26110833; 464,45.39444444; 465,44.02777778; 466,41.66111111; 467,
          42.47777778; 468,43.33610833; 469,40.01944167; 470,41.85833333; 471,
          63.10555278; 472,55.99444444; 473,57.96666389; 474,58.35833333; 475,
          60.025; 476,60.127775; 477,56.18610833; 478,60.85833333; 479,
          59.26388611; 480,54.43888889; 481,54.43888889; 482,59.44166389; 483,
          53.18333056; 484,54.05833333; 485,51.99166667; 486,57.11666667; 487,
          56.41666389; 488,54.97499722; 489,54.28610833; 490,54.002775; 491,
          54.24166389; 492,53.80555556; 493,56.62499722; 494,55.51111111; 495,
          55.59166389; 496,53.15833333; 497,54.44999722; 498,56.31111111; 499,
          52.66666389; 500,51.56388611; 501,57.23055556; 502,53.89722222; 503,
          55.28333056; 504,54.58055278; 505,54.51666389; 506,50.98888889; 507,
          55.96110833; 508,53.56388889; 509,55.07221944; 510,52.11944167; 511,
          52.60833333; 512,58.91666389; 513,55.08333333; 514,56.55; 515,
          54.03333056; 516,55.89444444; 517,53.65555278; 518,57.24999722; 519,
          56.14166667; 520,56.05833333; 521,53.13055278; 522,55.08333333; 523,
          52.31666667; 524,53.99166667; 525,52.07221944; 526,54.58888611; 527,
          58.38333056; 528,54.34999722]) "循环流量，kg/s"
      annotation (Placement(transformation(extent={{-362,-8},{-382,12}})));
    Modelica.Fluid.Sensors.Temperature temperature(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater) annotation (
        Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={-256,-70})));
    inner Modelica.Fluid.System system(
      p_ambient=300000,
      T_ambient=303.15,
      m_flow_start=4,
      use_eps_Re=true)
      annotation (Placement(transformation(extent={{334,110},{354,130}})));
    Modelica.Fluid.Sensors.Temperature temperature1(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater) annotation (
        Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=180,
          origin={-404,-12})));
    Modelica.Blocks.Sources.RealExpression realExpression13(y=time/3600)
      annotation (Placement(transformation(extent={{-502,-46},{-482,-26}})));
    Modelica.Blocks.Tables.CombiTable1Ds Tg(table=[0,318.88; 2,319.04; 4,319.19;
          6,319.4; 8,319.41; 10,319.66; 12,319.95; 14,319.17; 16,318.68; 18,
          317.77; 20,316.86; 22,316.26; 24,318.27; 26,319.2; 28,319.09; 30,
          319.22; 32,318.24; 34,318.3; 36,318.07; 38,317.98; 40,317.53; 42,
          316.78; 44,316.75; 46,317.14; 48,317.17; 50,317.13; 52,317.16; 54,
          317.17; 56,317.18; 58,317.82; 60,318.12; 62,318.15; 64,317.99; 66,
          317.82; 68,318.19; 70,318.16; 72,318.07; 74,318.34; 76,318.16; 78,
          318.19; 80,318.11; 82,317.74; 84,317.03; 86,317.32; 88,317.3; 90,
          317.08; 92,317.04; 94,317.18; 96,317.01; 98,317.13; 100,317.18; 102,
          317.19; 104,318.79; 106,319.01; 108,318.96; 110,318.09; 112,317.38;
          114,317.05; 116,317.23; 118,317.18; 120,317.1; 122,317.14; 124,317.24;
          126,317.05; 128,316.62; 130,315.15; 132,315.05; 134,314.22; 136,
          314.34; 138,314.59; 140,314.24; 142,314.19; 144,314.01; 146,314.25;
          148,314.26; 150,314.24; 152,314.25; 154,313.59; 156,312.39; 158,
          311.03; 160,310.47; 162,312.2; 164,311.67; 166,311.11; 168,311.17;
          170,311.19; 172,311.12; 174,311.03; 176,311.47; 178,312.58; 180,
          311.33; 182,310.19; 184,310.36; 186,310.35; 188,310.67; 190,310.48;
          192,310.82; 194,310.55; 196,310.57; 198,310.61; 200,310.65; 202,
          311.65; 204,312.24; 206,312.43; 208,313.35; 210,314.13; 212,314.62;
          214,315.38; 216,315.59; 218,315.64; 220,315.47; 222,315.8; 224,316.81;
          226,317.43; 228,317.84; 230,317.62; 232,318.26; 234,318.9; 236,318.77;
          238,319.23; 240,319.16; 242,319.19; 244,319.27; 246,319.07; 248,318.4;
          250,318.7; 252,318.71; 254,318.52; 256,318.44; 258,318.96; 260,318.5;
          262,318.58; 264,318.31; 266,318.81; 268,318.45; 270,318.84; 272,
          318.21; 274,318.21; 276,318.16; 278,317.64; 280,317.74; 282,317.2;
          284,317; 286,317.09; 288,317.27; 290,317.21; 292,317.11; 294,317.11;
          296,317.11; 298,317.24; 300,316.7; 302,316.71; 304,316.67; 306,316.62;
          308,316.72; 310,316.78; 312,316.63; 314,316.61; 316,316.67; 318,
          316.76; 320,316.78; 322,316.53; 324,316.58; 326,316.77; 328,316.41;
          330,316.11; 332,316.05; 334,316.1; 336,316.15; 338,316.09; 340,316.05;
          342,316.11; 344,316.32; 346,316.08; 348,316.22; 350,316.11; 352,
          317.11; 354,317.33; 356,317.74; 358,317.49; 360,317.64; 362,317.65;
          364,317.6; 366,317.7; 368,317.65; 370,317.67; 372,317.86; 374,318.7;
          376,319.29; 378,320.54; 380,320.59; 382,320.66; 384,320.58; 386,
          320.69; 388,320.55; 390,320.7; 392,320.7; 394,320.94; 396,321.14; 398,
          321.17; 400,321.09; 402,321.15; 404,321.16; 406,321.12; 408,321.07;
          410,321.12; 412,321.24; 414,321.09; 416,321.41; 418,322.16; 420,
          322.22; 422,322.16; 424,321.59; 426,321.6; 428,321.74; 430,321.64;
          432,321.73; 434,321.54; 436,321.61; 438,321.59; 440,321.65; 442,
          321.66; 444,321.82; 446,322.18; 448,322.1; 450,322.12; 452,322.62;
          454,322.57; 456,322.62; 458,322.72; 460,322.59; 462,322.61; 464,
          322.63; 466,322.13; 468,321.51; 470,321.03; 472,321.26; 474,321.19;
          476,321.16; 478,321.15; 480,321.22; 482,321.13; 484,321.14; 486,
          321.17; 488,321.09; 490,321.14; 492,320.65; 494,320.67; 496,320.66;
          498,320.52; 500,320.23; 502,320.11; 504,320.09; 506,320.15; 508,320.2;
          510,320.25; 512,320.1; 514,320.25; 516,320.12; 518,320.15; 520,320.19;
          522,320.11; 524,320.24; 526,320.22; 528,320.12; 530,320.16; 532,
          320.23; 534,320.21; 536,320.11; 538,319.93; 540,320.26; 542,320.08;
          544,320.27; 546,320.02; 548,320.04; 550,320.07; 552,320.22; 554,
          320.08; 556,320.22; 558,320.06; 560,320.06; 562,319.97; 564,319.31;
          566,319.38; 568,319.14; 570,319.48; 572,319.2; 574,319.11])
                                                        "供水温度"
      annotation (Placement(transformation(extent={{-468,-46},{-448,-26}})));
    Pipe pipe1(Length=72, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-192,-24},{-172,-4}})));
    Pipe pipe2(Length=72, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-190,-64},{-170,-44}})));
    Pipe pipe3(Length=78, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-152,16})));
    Pipe pipe4(Length=12, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-136,-22})));
    Pipe pipe5(Length=66, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-136,140})));
    User F8(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=3.23) "8栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-62,-2})));
    Modelica.Blocks.Tables.CombiTable1Ds F8_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#8负荷" annotation (Placement(transformation(extent={{-36,4},{-56,24}})));
    Modelica.Blocks.Sources.RealExpression realExpression8(y=time/3600)
      annotation (Placement(transformation(extent={{-8,4},{-28,24}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible4(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-60,-36})));

    Modelica.Blocks.Sources.Constant const4(k=1.000000)
      annotation (Placement(transformation(extent={{-36,-60},{-50,-46}})));
    User F5(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=3.23) "5栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-204,48})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible1(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-208,70})));

    Modelica.Blocks.Tables.CombiTable1Ds F5_load1(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#5负荷"
      annotation (Placement(transformation(extent={{-228,18},{-208,38}})));
    Modelica.Blocks.Sources.RealExpression realExpression1(y=time/3600)
      annotation (Placement(transformation(extent={{-256,18},{-236,38}})));
    Modelica.Blocks.Sources.Constant const1(k=0.749560)
      annotation (Placement(transformation(extent={{-232,80},{-218,94}})));
    Pipe pipe6(Length=6, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-102,-4})));
    Pipe pipe7(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-170,50})));
    Pipe pipe8(Length=8, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-152,72})));
    User F6(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=3.23) "6栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-52,96})));
    Modelica.Blocks.Tables.CombiTable1Ds F6_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#6负荷"
      annotation (Placement(transformation(extent={{-24,110},{-44,130}})));
    Modelica.Blocks.Sources.RealExpression realExpression4(y=time/3600)
      annotation (Placement(transformation(extent={{4,110},{-16,130}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible2(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-64,66})));

    Modelica.Blocks.Sources.Constant const2(k=0.619521)
      annotation (Placement(transformation(extent={{-46,40},{-60,54}})));
    Pipe pipe9(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-106,94})));
    Pipe pipe10(Length=8, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-152,120})));
    Pipe pipe11(Length=12, Diameter(displayUnit="mm") = 0.07)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-142,194})));
    Pipe pipe12(Length=12, Diameter(displayUnit="mm") = 0.07)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={-60,194})));
    User F4_1(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=3.23) "4栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-164,244})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible3(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-166,268})));

    Modelica.Blocks.Tables.CombiTable1Ds F4_1_load(table=[0,-39428.268; 2,-39230.136;
          4,-39428.268; 6,-36852.552; 8,-36852.552; 10,-36555.354; 12,-37347.882;
          14,-35663.76; 16,-36456.288; 18,-41211.456; 20,-39428.268; 22,-39230.136;
          24,-39428.268; 26,-36852.552; 28,-36852.552; 30,-36555.354; 32,-37347.882;
          34,-35663.76; 36,-36456.288; 38,-38140.41; 40,-39725.466; 42,-39329.202;
          44,-39626.4; 46,-40220.796; 48,-39824.532; 50,-39824.532; 52,-39527.334;
          54,-39032.004; 56,-38041.344; 58,-37347.882; 60,-36852.552; 62,-35465.628;
          64,-32889.912; 66,-33682.44; 68,-42003.984; 70,-43489.974; 72,-41904.918;
          74,-41013.324; 76,-47353.548; 78,-43787.172; 80,-43291.842; 82,-44480.634;
          84,-44183.436; 86,-44975.964; 88,-40418.928; 90,-38536.674; 92,-38734.806;
          94,-37942.278; 96,-52703.112; 98,-46065.69; 100,-47056.35; 102,-46263.822;
          104,-46461.954; 106,-46660.086; 108,-46660.086; 110,-45372.228; 112,-47353.548;
          114,-44777.832; 116,-43390.908; 118,-44084.37; 120,-41904.918; 122,-36852.552;
          124,-39527.334; 126,-40319.862; 128,-39923.598; 130,-40121.73; 132,-41013.324;
          134,-41409.588; 136,-39329.202; 138,-40121.73; 140,-42103.05; 142,-41013.324;
          144,-39824.532; 146,-40220.796; 148,-41112.39; 150,-38041.344; 152,-39032.004;
          154,-41310.522; 156,-40220.796; 158,-39329.202; 160,-41013.324; 162,-40716.126;
          164,-39329.202; 166,-38437.608; 168,-37050.684; 170,-36654.42; 172,-39329.202;
          174,-35762.826; 176,-37744.146; 178,-38140.41; 180,-38239.476; 182,-38635.74;
          184,-38338.542; 186,-38932.938; 188,-37248.816; 190,-37645.08; 192,-36159.09;
          194,-36060.024; 196,-38338.542; 198,-37149.75; 200,-34574.034; 202,-37248.816;
          204,-36258.156; 206,-37645.08; 208,-37248.816; 210,-37843.212; 212,-35861.892;
          214,-36654.42; 216,-35762.826; 218,-33286.176; 220,-31502.988; 222,-31205.79;
          224,-31007.658; 226,-28630.074; 228,-29917.932; 230,-35762.826; 232,-41805.852;
          234,-37546.014; 236,-38041.344; 238,-37248.816; 240,-38437.608; 242,-37446.948;
          244,-33286.176; 246,-37248.816; 248,-34871.232; 250,-35663.76; 252,-35465.628;
          254,-34871.232; 256,-35960.958; 258,-35366.562; 260,-33385.242; 262,-34375.902;
          264,-35267.496; 266,-44381.568; 268,-50820.858; 270,-46561.02; 272,-47056.35;
          274,-47056.35; 276,-46263.822; 278,-47056.35; 280,-47551.68; 282,-46362.888;
          284,-47254.482; 286,-50127.396; 288,-45768.492; 290,-47353.548; 292,-53297.508;
          294,-47848.878; 296,-59835.864; 298,-57458.28; 300,-53099.376; 302,-53891.904;
          304,-54684.432; 306,-54387.234; 308,-58647.072; 310,-58349.874; 312,-53990.97;
          314,-53297.508; 316,-60331.194; 318,-52207.782; 320,-63501.306; 322,-50622.726;
          324,-57755.478; 326,-56467.62; 328,-57260.148; 330,-56962.95; 332,-62114.382;
          334,-65977.956; 336,-64194.768; 338,-68652.738; 340,-56071.356; 342,-69643.398;
          344,-64987.296; 346,-71822.85; 348,-71921.916; 350,-76974.282; 352,-78757.47;
          354,-70237.794; 356,-79549.998; 358,-57359.214; 360,-63600.372; 362,-64194.768;
          364,-63005.976; 366,-63501.306; 368,-62807.844; 370,-62807.844; 372,-63501.306;
          374,-64789.164; 376,-63303.174; 378,-63204.108; 380,-61321.854; 382,-55476.96;
          384,-55377.894; 386,-54981.63; 388,-55576.026; 390,-56566.686; 392,-55278.828;
          394,-55873.224; 396,-57458.28; 398,-58349.874; 400,-59835.864; 402,-59835.864;
          404,-57260.148; 406,-55179.762; 408,-54783.498])
      "#4-1负荷"
      annotation (Placement(transformation(extent={{-210,218},{-190,238}})));
    Modelica.Blocks.Sources.RealExpression realExpression5(y=time/3600)
      annotation (Placement(transformation(extent={{-190,196},{-210,216}})));
    Modelica.Blocks.Sources.Constant const3(k=0.973089)
      annotation (Placement(transformation(extent={{-194,278},{-180,292}})));
    User F4_2(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=3.23) "4栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-76,252})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible5(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-78,276})));

    Modelica.Blocks.Tables.CombiTable1Ds F4_1_load1(table=[0,-96158.392; 2,-95675.184;
          4,-96158.392; 6,-89876.688; 8,-89876.688; 10,-89151.876; 12,-91084.708;
          14,-86977.44; 16,-88910.272; 18,-100507.264; 20,-96158.392; 22,-95675.184;
          24,-96158.392; 26,-89876.688; 28,-89876.688; 30,-89151.876; 32,-91084.708;
          34,-86977.44; 36,-88910.272; 38,-93017.54; 40,-96883.204; 42,-95916.788;
          44,-96641.6; 46,-98091.224; 48,-97124.808; 50,-97124.808; 52,-96399.996;
          54,-95191.976; 56,-92775.936; 58,-91084.708; 60,-89876.688; 62,-86494.232;
          64,-80212.528; 66,-82145.36; 68,-102440.096; 70,-106064.156; 72,-102198.492;
          74,-100024.056; 76,-115486.712; 78,-106788.968; 80,-105580.948; 82,-108480.196;
          84,-107755.384; 86,-109688.216; 88,-98574.432; 90,-93983.956; 92,-94467.164;
          94,-92534.332; 96,-128533.328; 98,-112345.86; 100,-114761.9; 102,-112829.068;
          104,-113312.276; 106,-113795.484; 108,-113795.484; 110,-110654.632;
          112,-115486.712; 114,-109205.008; 116,-105822.552; 118,-107513.78;
          120,-102198.492; 122,-89876.688; 124,-96399.996; 126,-98332.828; 128,
          -97366.412; 130,-97849.62; 132,-100024.056; 134,-100990.472; 136,-95916.788;
          138,-97849.62; 140,-102681.7; 142,-100024.056; 144,-97124.808; 146,-98091.224;
          148,-100265.66; 150,-92775.936; 152,-95191.976; 154,-100748.868; 156,
          -98091.224; 158,-95916.788; 160,-100024.056; 162,-99299.244; 164,-95916.788;
          166,-93742.352; 168,-90359.896; 170,-89393.48; 172,-95916.788; 174,-87219.044;
          176,-92051.124; 178,-93017.54; 180,-93259.144; 182,-94225.56; 184,-93500.748;
          186,-94950.372; 188,-90843.104; 190,-91809.52; 192,-88185.46; 194,-87943.856;
          196,-93500.748; 198,-90601.5; 200,-84319.796; 202,-90843.104; 204,-88427.064;
          206,-91809.52; 208,-90843.104; 210,-92292.728; 212,-87460.648; 214,-89393.48;
          216,-87219.044; 218,-81178.944; 220,-76830.072; 222,-76105.26; 224,-75622.052;
          226,-69823.556; 228,-72964.408; 230,-87219.044; 232,-101956.888; 234,
          -91567.916; 236,-92775.936; 238,-90843.104; 240,-93742.352; 242,-91326.312;
          244,-81178.944; 246,-90843.104; 248,-85044.608; 250,-86977.44; 252,-86494.232;
          254,-85044.608; 256,-87702.252; 258,-86252.628; 260,-81420.548; 262,-83836.588;
          264,-86011.024; 266,-108238.592; 268,-123942.852; 270,-113553.88; 272,
          -114761.9; 274,-114761.9; 276,-112829.068; 278,-114761.9; 280,-115969.92;
          282,-113070.672; 284,-115245.108; 286,-122251.624; 288,-111621.048;
          290,-115486.712; 292,-129982.952; 294,-116694.732; 296,-145928.816;
          298,-140130.32; 300,-129499.744; 302,-131432.576; 304,-133365.408;
          306,-132640.596; 308,-143029.568; 310,-142304.756; 312,-131674.18;
          314,-129982.952; 316,-147136.836; 318,-127325.308; 320,-154868.164;
          322,-123459.644; 324,-140855.132; 326,-137714.28; 328,-139647.112;
          330,-138922.3; 332,-151485.708; 334,-160908.264; 336,-156559.392; 338,
          -167431.572; 340,-136747.864; 342,-169847.612; 344,-158492.224; 346,-175162.9;
          348,-175404.504; 350,-187726.308; 352,-192075.18; 354,-171297.236;
          356,-194008.012; 358,-139888.716; 360,-155109.768; 362,-156559.392;
          364,-153660.144; 366,-154868.164; 368,-153176.936; 370,-153176.936;
          372,-154868.164; 374,-158009.016; 376,-154384.956; 378,-154143.352;
          380,-149552.876; 382,-135298.24; 384,-135056.636; 386,-134090.22; 388,
          -135539.844; 390,-137955.884; 392,-134815.032; 394,-136264.656; 396,-140130.32;
          398,-142304.756; 400,-145928.816; 402,-145928.816; 404,-139647.112;
          406,-134573.428; 408,-133607.012; 410,-137472.676; 412,-133848.616;
          414,-136023.052; 416,-128774.932; 418,-125875.684; 420,-123701.248;
          422,-117177.94; 424,-123459.644; 426,-117177.94; 428,-128291.724; 430,
          -106064.156; 432,-111137.84; 434,-113070.672; 436,-112345.86; 438,-116936.336;
          440,-122010.02; 442,-116453.128; 444,-115486.712; 446,-115969.92; 448,
          -115003.504; 450,-111862.652; 452,-126117.288; 454,-115003.504; 456,-107996.988;
          458,-119835.584; 460,-117902.752; 462,-106788.968; 464,-106305.76;
          466,-116211.524; 468,-117902.752; 470,-112104.256; 472,-119110.772;
          474,-115245.108; 476,-113795.484; 478,-117419.544; 480,-121768.416;
          482,-122493.228; 484,-111137.84; 486,-121526.812; 488,-116211.524;
          490,-113795.484; 492,-118385.96; 494,-114761.9; 496,-118144.356; 498,
          -133123.804; 500,-125150.872; 502,-117661.148; 504,-120560.396; 506,-118385.96;
          508,-114761.9; 510,-119110.772; 512,-128774.932; 514,-114278.692; 516,
          -119352.376; 518,-122493.228; 520,-137955.884; 522,-124184.456; 524,-135056.636;
          526,-112829.068; 528,-127808.516; 530,-120077.188; 532,-124667.664;
          534,-111137.84; 536,-122010.02; 538,-125150.872; 540,-122251.624; 542,
          -123701.248; 544,-126358.892; 546,-128533.328; 548,-122734.832; 550,-120802;
          552,-115969.92; 554,-116936.336; 556,-120560.396; 558,-116453.128;
          560,-124184.456; 562,-128291.724; 564,-121768.416; 566,-122251.624;
          568,-128050.12; 570,-122734.832; 572,-123942.852; 574,-123701.248;
          576,-119352.376; 578,-124667.664; 580,-121043.604; 582,-121043.604;
          584,-115728.316; 586,-118869.168; 588,-115003.504; 590,-119352.376;
          592,-138439.092; 594,-114278.692; 596,-138922.3; 598,-131674.18; 600,
          -141096.736; 602,-133848.616; 604,-141338.34; 606,-145928.816; 608,-153176.936;
          610,-154384.956; 612,-161391.472; 614,-159941.848; 616,-177820.544;
          618,-174921.296; 620,-187484.704; 622,-182169.416; 624,-187726.308;
          626,-189659.14; 628,-181444.604; 630,-187967.912; 632,-186759.892;
          634,-190142.348; 636,-192799.992; 638,-197148.864; 640,-198840.092;
          642,-189659.14; 644,-203430.568; 646,-184343.852; 648,-186759.892;
          650,-179270.168; 652,-180478.188; 654,-167431.572; 656,-168881.196;
          658,-176854.128; 660,-164532.324; 662,-173471.672; 664,-156559.392;
          666,-160183.452; 668,-150277.688; 670,-129016.536; 672,-135781.448;
          674,-151727.312; 676,-139647.112; 678,-141096.736; 680,-136506.26;
          682,-173471.672; 684,-137955.884; 686,-161874.68; 688,-158009.016;
          690,-190142.348; 692,-178303.752; 694,-194491.22; 696,-186759.892;
          698,-208745.856; 700,-209953.876; 702,-210678.688; 704,-215993.976;
          706,-224450.116; 708,-230007.008; 710,-239187.96; 712,-238463.148;
          714,-234597.484; 716,-229765.404; 718,-211403.5; 720,-217443.6; 722,-211645.104;
          724,-216235.58; 726,-205846.608; 728,-209470.668; 730,-209470.668;
          732,-219859.64; 734,-205605.004; 736,-161149.868; 738,-87702.252; 740,
          -85286.212; 742,-101473.68; 744,-92051.124; 746,-102198.492; 748,-107755.384;
          750,-163565.908; 752,-119835.584; 754,-181203; 756,-272770.916; 758,-207537.836;
          760,-213819.54; 762,-212128.312; 764,-207296.232; 766,-204155.38; 768,
          -198840.092; 770,-215027.56; 772,-194249.616; 774,-201980.944; 776,-197390.468;
          778,-207537.836; 780,-211403.5; 782,-212853.124; 784,-223966.908; 786,
          -234839.088; 788,-223242.096; 790,-224208.512; 792,-233872.672; 794,-241120.792;
          796,-244744.852; 798,-234839.088; 800,-227107.76; 802,-228315.78; 804,
          -225899.74; 806,-232664.652; 808,-233389.464; 810,-228798.988; 812,-209229.064;
          814,-211161.896; 816,-201256.132; 818,-211886.708; 820,-208021.044;
          822,-201497.736; 824,-196182.448; 826,-202705.756; 828,-197873.676;
          830,-200289.716; 832,-204880.192; 834,-201256.132; 836,-196182.448;
          838,-187726.308; 840,-189417.536; 842,-188692.724; 844,-191833.576;
          846,-190625.556; 848,-184343.852; 850,-190142.348; 852,-192075.18;
          854,-201256.132; 856,-207537.836; 858,-209953.876; 860,-210678.688;
          862,-214785.956])
      "#4-1负荷"
      annotation (Placement(transformation(extent={{-102,222},{-82,242}})));
    Modelica.Blocks.Sources.RealExpression realExpression6(y=time/3600)
      annotation (Placement(transformation(extent={{-80,200},{-100,220}})));
    Modelica.Blocks.Sources.Constant const5(k=0.803945)
      annotation (Placement(transformation(extent={{-94,290},{-80,304}})));
    Pipe pipe13(Length=78, Diameter(displayUnit="mm") = 0.2)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-26,176})));
    Pipe pipe14(Length=12, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={36,198})));
    Pipe pipe15(Length=12, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={114,198})));
    User F3_1(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=2.37) "3栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={14,248})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible6(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={12,272})));

    Modelica.Blocks.Tables.CombiTable1Ds F3_1_load(table=[0,-85295.826; 2,-87079.014;
          4,-88168.74; 6,-89852.862; 8,-89456.598; 10,-89852.862; 12,-91239.786;
          14,-84107.034; 16,-80936.922; 18,-78460.272; 20,-74299.5; 22,-75785.49;
          24,-85097.694; 26,-91437.918; 28,-86088.354; 30,-87277.146; 32,-80540.658;
          34,-85295.826; 36,-82621.044; 38,-82026.648; 40,-80243.46; 42,-75488.292;
          44,-76181.754; 46,-80441.592; 48,-80936.922; 50,-80837.856; 52,-81234.12;
          54,-81333.186; 56,-82026.648; 58,-85097.694; 60,-84305.166; 62,-83710.77;
          64,-82323.846; 66,-80837.856; 68,-84800.496; 70,-84503.298; 72,-83710.77;
          74,-86385.552; 76,-84602.364; 78,-84800.496; 80,-84107.034; 82,-81035.988;
          84,-77370.546; 86,-81234.12; 88,-80936.922; 90,-78460.272; 92,-78163.074;
          94,-79748.13; 96,-78559.338; 98,-80441.592; 100,-81135.054; 102,-81531.318;
          104,-91140.72; 106,-88267.806; 108,-88862.202; 110,-81432.252; 112,-79252.8;
          114,-78955.602; 116,-80936.922; 118,-80540.658; 120,-79649.064; 122,-80144.394;
          124,-81035.988; 126,-79252.8; 128,-76776.15; 130,-70435.926; 132,-71129.388;
          134,-65482.626; 136,-69346.2; 138,-69544.332; 140,-67265.814; 142,-68157.408;
          144,-66473.286; 146,-68652.738; 148,-68949.936; 150,-68850.87; 152,-68850.87;
          154,-62906.91; 156,-56863.884; 158,-51712.452; 160,-54684.432; 162,-63501.306;
          164,-56467.62; 166,-54585.366; 168,-56764.818; 170,-57359.214; 172,-56764.818;
          174,-55972.29; 176,-60133.062; 178,-63600.372; 180,-51712.452; 182,-49632.066;
          184,-54486.3; 186,-52009.65; 188,-54189.102; 190,-52108.716; 192,-55278.828;
          194,-52405.914; 196,-52703.112; 198,-54090.036; 200,-55476.96; 202,-62510.646;
          204,-63699.438; 206,-63699.438; 208,-68256.474; 210,-70237.794; 212,-73804.17;
          214,-76181.754; 216,-75587.358; 218,-75686.424; 220,-74398.566; 222,-78262.14;
          224,-84800.496; 226,-85791.156; 228,-85692.09; 230,-82918.242; 232,-87673.41;
          234,-90348.192; 236,-88664.07; 238,-90744.456; 240,-89456.598; 242,-89753.796;
          244,-90744.456; 246,-88664.07; 248,-84701.43; 250,-89654.73; 252,-87574.344;
          254,-84800.496; 256,-84404.232; 258,-90150.06; 260,-85394.892; 262,-86187.42;
          264,-83611.704; 266,-88664.07; 268,-85295.826; 270,-89258.466; 272,-85394.892;
          274,-86286.486; 276,-84800.496; 278,-79946.262; 280,-83611.704; 282,-80540.658;
          284,-79549.998; 286,-80540.658; 288,-82621.044; 290,-82125.714; 292,-81333.186;
          294,-81531.318; 296,-82026.648; 298,-82819.176; 300,-78658.404; 302,-79450.932;
          304,-79153.734; 306,-78955.602; 308,-80045.328; 310,-80738.79; 312,-79252.8;
          314,-79351.866; 316,-80243.46; 318,-81531.318; 320,-82026.648; 322,-79549.998;
          324,-79847.196; 326,-81135.054; 328,-77370.546; 330,-76677.084; 332,-76776.15;
          334,-77172.414; 336,-77172.414; 338,-76578.018; 340,-76379.886; 342,-77172.414;
          344,-80243.46; 346,-77766.81; 348,-78559.338; 350,-76875.216; 352,-84899.562;
          354,-83809.836; 356,-86187.42; 358,-82224.78; 360,-83710.77; 362,-84206.1;
          364,-84107.034; 366,-85394.892; 368,-85593.024; 370,-86385.552; 372,-87079.014;
          374,-90546.324; 376,-94608.03; 378,-100651.056; 380,-96886.548; 382,-97580.01;
          384,-96886.548; 386,-98174.406; 388,-96985.614; 390,-98570.67; 392,-98966.934;
          394,-100452.924; 396,-99165.066; 398,-98768.802; 400,-97976.274; 402,
          -98768.802; 404,-98867.868; 406,-98273.472; 408,-98273.472; 410,-98966.934;
          412,-100551.99; 414,-99363.198; 416,-102731.442; 418,-105009.96; 420,
          -103325.838; 422,-102037.98; 424,-98570.67; 426,-100849.188; 428,-103127.706;
          430,-102731.442; 432,-104019.3; 434,-102632.376; 436,-103623.036; 438,
          -103920.234; 440,-105109.026; 442,-104613.696; 444,-104910.894; 446,-105406.224;
          448,-104514.63; 450,-105505.29; 452,-109170.732; 454,-107189.412; 456,
          -107783.808; 458,-109071.666; 460,-107585.676; 462,-108279.138; 464,-108675.402;
          466,-104217.432; 468,-101146.386; 470,-98669.736; 472,-101740.782;
          474,-101740.782; 476,-101443.584; 478,-101344.518; 480,-102037.98;
          482,-101344.518; 484,-101641.716; 486,-102037.98; 488,-101740.782;
          490,-101542.65; 492,-97778.142; 494,-97877.208; 496,-98273.472; 498,-97183.746;
          500,-95400.558; 502,-96193.086; 504,-96391.218; 506,-97381.878; 508,-98075.34;
          510,-99066; 512,-98075.34; 514,-98768.802; 516,-96094.02; 518,-95499.624;
          520,-96292.152; 522,-96391.218; 524,-97976.274; 526,-97679.076; 528,-96985.614;
          530,-97580.01; 532,-98471.604; 534,-98273.472; 536,-97679.076; 538,-95400.558;
          540,-97580.01; 542,-95004.294; 544,-97381.878; 546,-95499.624; 548,-95796.822;
          550,-96094.02; 552,-97679.076; 554,-96391.218; 556,-97877.208; 558,-96391.218;
          560,-96787.482; 562,-95499.624; 564,-92725.776; 566,-93419.238; 568,-91140.72;
          570,-93221.106; 572,-92230.446; 574,-91735.116])   "#3-1负荷"
      annotation (Placement(transformation(extent={{-10,218},{10,238}})));
    Modelica.Blocks.Sources.RealExpression realExpression7(y=time/3600)
      annotation (Placement(transformation(extent={{10,196},{-10,216}})));
    Modelica.Blocks.Sources.Constant const6(k=0.923102)
      annotation (Placement(transformation(extent={{-16,282},{-2,296}})));
    User F3_2(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=3.23) "3栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={98,256})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible7(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={96,280})));

    Modelica.Blocks.Tables.CombiTable1Ds F3_2_load(table=[0,-100507.264; 2,-95675.184;
          4,-89876.688; 6,-89151.876; 8,-86977.44; 10,-93017.54; 12,-95916.788;
          14,-98091.224; 16,-97124.808; 18,-100507.264; 20,-95675.184; 22,-89876.688;
          24,-89151.876; 26,-86977.44; 28,-93017.54; 30,-95916.788; 32,-98091.224;
          34,-97124.808; 36,-96399.996; 38,-92775.936; 40,-89876.688; 42,-80212.528;
          44,-102440.096; 46,-106064.156; 48,-102198.492; 50,-100024.056; 52,-115486.712;
          54,-106788.968; 56,-105580.948; 58,-108480.196; 60,-107755.384; 62,-109688.216;
          64,-98574.432; 66,-93983.956; 68,-94467.164; 70,-92534.332; 72,-128533.328;
          74,-112345.86; 76,-114761.9; 78,-112829.068; 80,-113312.276; 82,-113795.484;
          84,-113795.484; 86,-110654.632; 88,-115486.712; 90,-109205.008; 92,-105822.552;
          94,-107513.78; 96,-102198.492; 98,-89876.688; 100,-96399.996; 102,-98332.828;
          104,-97366.412; 106,-97849.62; 108,-100024.056; 110,-100990.472; 112,
          -95916.788; 114,-97849.62; 116,-102681.7; 118,-100024.056; 120,-97124.808;
          122,-98091.224; 124,-100265.66; 126,-92775.936; 128,-95191.976; 130,-100748.868;
          132,-98091.224; 134,-95916.788; 136,-100024.056; 138,-99299.244; 140,
          -95916.788; 142,-93742.352; 144,-90359.896; 146,-89393.48; 148,-95916.788;
          150,-87219.044; 152,-92051.124; 154,-93017.54; 156,-93259.144; 158,-94225.56;
          160,-93500.748; 162,-94950.372; 164,-90843.104; 166,-91809.52; 168,-88185.46;
          170,-87943.856; 172,-93500.748; 174,-90601.5; 176,-84319.796; 178,-90843.104;
          180,-88427.064; 182,-91809.52; 184,-90843.104; 186,-92292.728; 188,-87460.648;
          190,-89393.48; 192,-87219.044; 194,-81178.944; 196,-76830.072; 198,-76105.26;
          200,-75622.052; 202,-69823.556; 204,-72964.408; 206,-87219.044; 208,-101956.888;
          210,-91567.916; 212,-92775.936; 214,-90843.104; 216,-93742.352; 218,-91326.312;
          220,-81178.944; 222,-90843.104; 224,-85044.608; 226,-86977.44; 228,-86494.232;
          230,-85044.608; 232,-87702.252; 234,-86252.628; 236,-81420.548; 238,-83836.588;
          240,-86011.024; 242,-108238.592; 244,-123942.852; 246,-113553.88; 248,
          -114761.9; 250,-114761.9; 252,-112829.068; 254,-114761.9; 256,-115969.92;
          258,-113070.672; 260,-115245.108; 262,-122251.624; 264,-111621.048;
          266,-115486.712; 268,-129982.952; 270,-116694.732; 272,-145928.816;
          274,-140130.32; 276,-129499.744; 278,-131432.576; 280,-133365.408;
          282,-132640.596; 284,-143029.568; 286,-142304.756; 288,-131674.18;
          290,-129982.952; 292,-147136.836; 294,-127325.308; 296,-154868.164;
          298,-123459.644; 300,-140855.132; 302,-137714.28; 304,-139647.112;
          306,-138922.3; 308,-151485.708; 310,-160908.264; 312,-156559.392; 314,
          -167431.572; 316,-136747.864; 318,-169847.612; 320,-158492.224; 322,-175162.9;
          324,-175404.504; 326,-187726.308; 328,-192075.18; 330,-171297.236;
          332,-194008.012; 334,-139888.716; 336,-155109.768; 338,-156559.392;
          340,-153660.144; 342,-154868.164; 344,-153176.936; 346,-153176.936;
          348,-154868.164; 350,-158009.016; 352,-154384.956; 354,-154143.352;
          356,-149552.876; 358,-135298.24; 360,-135056.636; 362,-134090.22; 364,
          -135539.844; 366,-137955.884; 368,-134815.032; 370,-136264.656; 372,-140130.32;
          374,-142304.756; 376,-145928.816; 378,-145928.816; 380,-139647.112;
          382,-134573.428; 384,-133607.012; 386,-137472.676; 388,-133848.616;
          390,-136023.052; 392,-128774.932; 394,-125875.684; 396,-123701.248;
          398,-117177.94; 400,-123459.644; 402,-117177.94; 404,-128291.724; 406,
          -106064.156; 408,-111137.84; 410,-113070.672; 412,-112345.86; 414,-116936.336;
          416,-122010.02; 418,-116453.128; 420,-115486.712; 422,-115969.92; 424,
          -115003.504; 426,-111862.652; 428,-126117.288; 430,-115003.504; 432,-107996.988;
          434,-119835.584; 436,-117902.752; 438,-106788.968; 440,-106305.76;
          442,-116211.524; 444,-117902.752; 446,-112104.256; 448,-119110.772;
          450,-115245.108; 452,-113795.484; 454,-117419.544; 456,-121768.416;
          458,-122493.228; 460,-111137.84; 462,-121526.812; 464,-116211.524;
          466,-113795.484; 468,-118385.96; 470,-114761.9; 472,-118144.356; 474,
          -133123.804; 476,-125150.872; 478,-117661.148; 480,-120560.396; 482,-118385.96;
          484,-114761.9; 486,-119110.772; 488,-128774.932; 490,-114278.692; 492,
          -119352.376; 494,-122493.228; 496,-137955.884; 498,-124184.456; 500,-135056.636;
          502,-112829.068; 504,-127808.516; 506,-120077.188; 508,-124667.664;
          510,-111137.84; 512,-122010.02; 514,-125150.872; 516,-122251.624; 518,
          -123701.248; 520,-126358.892; 522,-128533.328; 524,-122734.832; 526,-120802;
          528,-115969.92; 530,-116936.336; 532,-120560.396; 534,-116453.128;
          536,-124184.456; 538,-128291.724; 540,-121768.416; 542,-122251.624;
          544,-128050.12; 546,-122734.832; 548,-123942.852; 550,-123701.248;
          552,-119352.376; 554,-124667.664; 556,-121043.604; 558,-121043.604;
          560,-115728.316; 562,-118869.168; 564,-115003.504; 566,-119352.376;
          568,-138439.092; 570,-114278.692; 572,-138922.3; 574,-131674.18; 576,
          -141096.736; 578,-133848.616; 580,-141338.34; 582,-145928.816; 584,-153176.936;
          586,-154384.956; 588,-161391.472; 590,-159941.848; 592,-177820.544;
          594,-174921.296; 596,-187484.704; 598,-182169.416; 600,-187726.308;
          602,-189659.14; 604,-181444.604; 606,-187967.912; 608,-186759.892;
          610,-190142.348; 612,-192799.992; 614,-197148.864; 616,-198840.092;
          618,-189659.14; 620,-203430.568; 622,-184343.852; 624,-186759.892;
          626,-179270.168; 628,-180478.188; 630,-167431.572; 632,-168881.196;
          634,-176854.128; 636,-164532.324; 638,-173471.672; 640,-156559.392;
          642,-160183.452; 644,-150277.688; 646,-129016.536; 648,-135781.448;
          650,-151727.312; 652,-139647.112; 654,-141096.736; 656,-136506.26;
          658,-173471.672; 660,-137955.884; 662,-161874.68; 664,-158009.016;
          666,-190142.348; 668,-178303.752; 670,-194491.22; 672,-186759.892;
          674,-208745.856; 676,-209953.876; 678,-210678.688; 680,-215993.976;
          682,-224450.116; 684,-230007.008; 686,-239187.96; 688,-238463.148;
          690,-234597.484; 692,-229765.404; 694,-211403.5; 696,-217443.6; 698,-211645.104;
          700,-216235.58; 702,-205846.608; 704,-209470.668; 706,-209470.668;
          708,-219859.64; 710,-205605.004; 712,-161149.868; 714,-87702.252; 716,
          -85286.212; 718,-101473.68; 720,-92051.124; 722,-102198.492; 724,-107755.384;
          726,-163565.908; 728,-119835.584; 730,-181203; 732,-272770.916; 734,-207537.836;
          736,-213819.54; 738,-212128.312; 740,-207296.232; 742,-204155.38; 744,
          -198840.092; 746,-215027.56; 748,-194249.616; 750,-201980.944; 752,-197390.468;
          754,-207537.836; 756,-211403.5; 758,-212853.124; 760,-223966.908; 762,
          -234839.088; 764,-223242.096; 766,-224208.512; 768,-233872.672; 770,-241120.792;
          772,-244744.852; 774,-234839.088; 776,-227107.76; 778,-228315.78; 780,
          -225899.74; 782,-232664.652; 784,-233389.464; 786,-228798.988; 788,-209229.064;
          790,-211161.896; 792,-201256.132; 794,-211886.708; 796,-208021.044;
          798,-201497.736; 800,-196182.448; 802,-202705.756; 804,-197873.676;
          806,-200289.716; 808,-204880.192; 810,-207537.836; 812,-202464.152;
          814,-197148.864; 816,-195457.636; 818,-189417.536; 820,-181203; 822,-186518.288;
          824,-191108.764; 826,-182652.624; 828,-180961.396; 830,-176854.128;
          832,-161633.076; 834,-157525.808; 836,-146895.232; 838,-154626.56;
          840,-146170.42; 842,-207537.836; 844,-202464.152; 846,-197148.864;
          848,-195457.636; 850,-189417.536; 852,-181203; 854,-186518.288; 856,-191108.764;
          858,-182652.624; 860,-180961.396; 862,-176854.128; 864,-161633.076;
          866,-157525.808; 868,-146895.232; 870,-154626.56; 872,-146170.42; 874,
          -138439.092; 876,-140613.528; 878,-143995.984; 880,-139163.904; 882,-140130.32;
          884,-143271.172; 886,-137714.28; 888,-143995.984; 890,-141338.34; 892,
          -143995.984; 894,-155351.372; 896,-156559.392; 898,-151002.5; 900,-152452.124;
          902,-154143.352; 904,-168881.196; 906,-178062.148; 908,-164532.324;
          910,-165981.948; 912,-170814.028; 914,-170089.216; 916,-166223.552;
          918,-169847.612; 920,-165981.948; 922,-168639.592; 924,-168881.196;
          926,-166948.364; 928,-172022.048; 930,-173471.672; 932,-170330.82;
          934,-171780.444; 936,-169364.404; 938,-168881.196; 940,-164773.928;
          942,-162599.492; 944,-157767.412; 946,-153418.54; 948,-153418.54; 950,
          -157042.6; 952,-158975.432; 954,-151727.312; 956,-163324.304; 958,-153176.936;
          960,-147861.648; 962,-148103.252; 964,-142063.152; 966,-142304.756;
          968,-133123.804; 970,-131915.784; 972,-128291.724; 974,-129258.14;
          976,-148103.252; 978,-190625.556; 980,-200048.112; 982,-193524.804;
          984,-186276.684; 986,-174921.296; 988,-179270.168; 990,-180961.396;
          992,-179753.376; 994,-180478.188; 996,-198598.488; 998,-185310.268;
          1000,-188451.12; 1002,-158975.432; 1004,-151727.312; 1006,-163324.304;
          1008,-153176.936; 1010,-147861.648; 1012,-148103.252; 1014,-142063.152;
          1016,-142304.756; 1018,-133123.804; 1020,-131915.784; 1022,-128291.724;
          1024,-129258.14; 1026,-148103.252; 1028,-190625.556; 1030,-200048.112;
          1032,-193524.804; 1034,-186276.684; 1036,-174921.296; 1038,-179270.168;
          1040,-180961.396; 1042,-179753.376; 1044,-180478.188; 1046,-198598.488;
          1048,-185310.268; 1050,-188451.12; 1052,-200048.112; 1054,-193524.804;
          1056,-186276.684; 1058,-174921.296; 1060,-179270.168; 1062,-180961.396;
          1064,-179753.376; 1066,-180478.188; 1068,-198598.488; 1070,-185310.268;
          1072,-205121.796; 1074,-199081.696; 1076,-203430.568; 1078,-222758.888;
          1080,-219376.432; 1082,-231939.84; 1084,-226624.552; 1086,-229765.404;
          1088,-231698.236; 1090,-231215.028; 1092,-226866.156; 1094,-230248.612;
          1096,-228557.384; 1098,-230973.424; 1100,-230007.008; 1102,-224933.324;
          1104,-220584.452; 1106,-222034.076; 1108,-221792.472; 1110,-222275.68;
          1112,-222758.888; 1114,-219376.432; 1116,-219376.432; 1118,-231939.84;
          1120,-226624.552; 1122,-229765.404; 1124,-231698.236; 1126,-231215.028;
          1128,-226866.156; 1130,-230248.612; 1132,-228557.384; 1134,-230973.424;
          1136,-230007.008; 1138,-224933.324; 1140,-220584.452; 1142,-224933.324;
          1144,-220584.452; 1146,-222034.076; 1148,-221792.472; 1150,-222275.68;
          1152,-216718.788; 1154,-218168.412; 1156,-217926.808; 1158,-208987.46;
          1160,-205121.796; 1162,-195216.032; 1164,-196907.26; 1166,-196424.052;
          1168,-194008.012; 1170,-182652.624; 1172,-182652.624; 1174,-204880.192;
          1176,-196907.26; 1178,-196424.052; 1180,-194008.012; 1182,-182652.624;
          1184,-204880.192; 1186,-203430.568; 1188,-203430.568; 1190,-210437.084;
          1192,-215752.372; 1194,-215752.372; 1196,-210437.084; 1198,-213577.936;
          1200,-208745.856; 1202,-213819.54; 1204,-220584.452; 1206,-207779.44;
          1208,-217685.204; 1210,-221309.264; 1212,-211886.708; 1214,-218168.412;
          1216,-216718.788; 1218,-229765.404; 1220,-226141.344; 1222,-229040.592;
          1224,-230248.612; 1226,-239671.168; 1228,-234114.276; 1230,-236288.712;
          1232,-234839.088; 1234,-237738.336; 1236,-231698.236; 1238,-235322.296;
          1240,-229040.592; 1242,-235322.296; 1244,-229040.592; 1246,-236530.316;
          1248,-230731.82; 1250,-231215.028; 1252,-231456.632; 1254,-231939.84;
          1256,-227349.364; 1258,-223725.304; 1260,-220342.848; 1262,-222758.888;
          1264,-219618.036; 1266,-224691.72; 1268,-211403.5; 1270,-209229.064;
          1272,-207537.836; 1274,-214061.144; 1276,-214302.748; 1278,-215752.372;
          1280,-217201.996; 1282,-211886.708; 1284,-206813.024; 1286,-206813.024;
          1288,-208745.856; 1290,-212128.312; 1292,-211645.104; 1294,-211645.104;
          1296,-219618.036; 1298,-202947.36; 1300,-208745.856; 1302,-214061.144;
          1304,-211886.708; 1306,-210437.084; 1308,-208504.252; 1310,-209953.876;
          1312,-206813.024; 1314,-219376.432; 1316,-204396.984; 1318,-217201.996;
          1320,-205363.4; 1322,-210920.292; 1324,-205605.004; 1326,-211161.896;
          1328,-205121.796; 1330,-208021.044; 1332,-205121.796; 1334,-208745.856;
          1336,-226624.552; 1338,-214544.352; 1340,-200048.112; 1342,-205363.4;
          1344,-205605.004; 1346,-207054.628; 1348,-206571.42; 1350,-209470.668;
          1352,-209229.064; 1354,-207054.628; 1356,-211403.5; 1358,-213577.936;
          1360,-212853.124; 1362,-205605.004; 1364,-209470.668; 1366,-209229.064;
          1368,-207054.628; 1370,-211403.5; 1372,-213577.936; 1374,-212853.124;
          1376,-205605.004; 1378,-209953.876; 1380,-207537.836; 1382,-210195.48;
          1384,-211403.5; 1386,-208262.648; 1388,-210437.084; 1390,-204880.192;
          1392,-213336.332; 1394,-207054.628; 1396,-199564.904; 1398,-208262.648;
          1400,-211403.5; 1402,-206329.816; 1404,-201014.528; 1406,-199081.696;
          1408,-199323.3; 1410,-197390.468; 1412,-208504.252; 1414,-208504.252])
      "#3_2负荷"
      annotation (Placement(transformation(extent={{72,226},{92,246}})));
    Modelica.Blocks.Sources.RealExpression realExpression9(y=time/3600)
      annotation (Placement(transformation(extent={{94,204},{74,224}})));
    Modelica.Blocks.Sources.Constant const7(k=0.799988)
      annotation (Placement(transformation(extent={{76,290},{90,304}})));
    Pipe pipe16(Length=78, Diameter(displayUnit="mm") = 0.2)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={138,176})));

    Pipe pipe18(Length=72, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={270,176})));
    Pipe pipe19(Length=12, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={342,196})));
    User F1(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=5.78) "1栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={326,254})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible9(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={324,278})));

    Modelica.Blocks.Tables.CombiTable1Ds F1oad(table=[0,-208021.044; 2,-212369.916;
          4,-215027.56; 6,-219134.828; 8,-218168.412; 10,-219134.828; 12,-222517.284;
          14,-205121.796; 16,-197390.468; 18,-191350.368; 20,-181203; 22,-184827.06;
          24,-207537.836; 26,-223000.492; 28,-209953.876; 30,-212853.124; 32,-196424.052;
          34,-208021.044; 36,-201497.736; 38,-200048.112; 40,-195699.24; 42,-184102.248;
          44,-185793.476; 46,-196182.448; 48,-197390.468; 50,-197148.864; 52,-198115.28;
          54,-198356.884; 56,-200048.112; 58,-207537.836; 60,-205605.004; 62,-204155.38;
          64,-200772.924; 66,-197148.864; 68,-206813.024; 70,-206088.212; 72,-204155.38;
          74,-210678.688; 76,-206329.816; 78,-206813.024; 80,-205121.796; 82,-197632.072;
          84,-188692.724; 86,-198115.28; 88,-197390.468; 90,-191350.368; 92,-190625.556;
          94,-194491.22; 96,-191591.972; 98,-196182.448; 100,-197873.676; 102,-198840.092;
          104,-222275.68; 106,-215269.164; 108,-216718.788; 110,-198598.488;
          112,-193283.2; 114,-192558.388; 116,-197390.468; 118,-196424.052; 120,
          -194249.616; 122,-195457.636; 124,-197632.072; 126,-193283.2; 128,-187243.1;
          130,-171780.444; 132,-173471.672; 134,-159700.244; 136,-169122.8; 138,
          -169606.008; 140,-164049.116; 142,-166223.552; 144,-162116.284; 146,-167431.572;
          148,-168156.384; 150,-167914.78; 152,-167914.78; 154,-153418.54; 156,
          -138680.696; 158,-126117.288; 160,-133365.408; 162,-154868.164; 164,-137714.28;
          166,-133123.804; 168,-138439.092; 170,-139888.716; 172,-138439.092;
          174,-136506.26; 176,-146653.628; 178,-155109.768; 180,-126117.288;
          182,-121043.604; 184,-132882.2; 186,-126842.1; 188,-132157.388; 190,-127083.704;
          192,-134815.032; 194,-127808.516; 196,-128533.328; 198,-131915.784;
          200,-135298.24; 202,-152452.124; 204,-155351.372; 206,-155351.372;
          208,-166465.156; 210,-171297.236; 212,-179994.98; 214,-185793.476;
          216,-184343.852; 218,-184585.456; 220,-181444.604; 222,-190867.16;
          224,-206813.024; 226,-209229.064; 228,-208987.46; 230,-202222.548;
          232,-213819.54; 234,-220342.848; 236,-216235.58; 238,-221309.264; 240,
          -218168.412; 242,-218893.224; 244,-221309.264; 246,-216235.58; 248,-206571.42;
          250,-218651.62; 252,-213577.936; 254,-206813.024; 256,-205846.608;
          258,-219859.64; 260,-208262.648; 262,-210195.48; 264,-203913.776; 266,
          -216235.58; 268,-208021.044; 270,-217685.204; 272,-208262.648; 274,-210437.084;
          276,-206813.024; 278,-194974.428; 280,-203913.776; 282,-196424.052;
          284,-194008.012; 286,-196424.052; 288,-201497.736; 290,-200289.716;
          292,-198356.884; 294,-198840.092; 296,-200048.112; 298,-201980.944;
          300,-191833.576; 302,-193766.408; 304,-193041.596; 306,-192558.388;
          308,-195216.032; 310,-196907.26; 312,-193283.2; 314,-193524.804; 316,
          -195699.24; 318,-198840.092; 320,-200048.112; 322,-194008.012; 324,-194732.824;
          326,-197873.676; 328,-188692.724; 330,-187001.496; 332,-187243.1; 334,
          -188209.516; 336,-188209.516; 338,-186759.892; 340,-186276.684; 342,-188209.516;
          344,-195699.24; 346,-189659.14; 348,-191591.972; 350,-187484.704; 352,
          -207054.628; 354,-204396.984; 356,-210195.48; 358,-200531.32; 360,-204155.38;
          362,-205363.4; 364,-205121.796; 366,-208262.648; 368,-208745.856; 370,
          -210678.688; 372,-212369.916; 374,-220826.056; 376,-230731.82; 378,-245469.664;
          380,-236288.712; 382,-237979.94; 384,-236288.712; 386,-239429.564;
          388,-236530.316; 390,-240395.98; 392,-241362.396; 394,-244986.456;
          396,-241845.604; 398,-240879.188; 400,-238946.356; 402,-240879.188;
          404,-241120.792; 406,-239671.168; 408,-239671.168; 410,-241362.396;
          412,-245228.06; 414,-242328.812; 416,-250543.348; 418,-256100.24; 420,
          -251992.972; 422,-248852.12; 424,-240395.98; 426,-245952.872; 428,-251509.764;
          430,-250543.348; 432,-253684.2; 434,-250301.744; 436,-252717.784; 438,
          -253442.596; 440,-256341.844; 442,-255133.824; 444,-255858.636; 446,-257066.656;
          448,-254892.22; 450,-257308.26; 452,-266247.608; 454,-261415.528; 456,
          -262865.152; 458,-266006.004; 460,-262381.944; 462,-264073.172; 464,-265039.588;
          466,-254167.408; 468,-246677.684; 470,-240637.584; 472,-248127.308;
          474,-248127.308; 476,-247402.496; 478,-247160.892; 480,-248852.12;
          482,-247160.892; 484,-247885.704; 486,-248852.12; 488,-248127.308;
          490,-247644.1; 492,-238463.148; 494,-238704.752; 496,-239671.168; 498,
          -237013.524; 500,-232664.652; 502,-234597.484; 504,-235080.692; 506,-237496.732;
          508,-239187.96; 510,-241604; 512,-239187.96; 514,-240879.188; 516,-234355.88;
          518,-232906.256; 520,-234839.088; 522,-235080.692; 524,-238946.356;
          526,-238221.544; 528,-236530.316; 530,-237979.94; 532,-240154.376;
          534,-239671.168; 536,-238221.544; 538,-232664.652; 540,-237979.94;
          542,-231698.236; 544,-237496.732; 546,-232906.256; 548,-233631.068;
          550,-234355.88; 552,-238221.544; 554,-235080.692; 556,-238704.752;
          558,-235080.692; 560,-236047.108; 562,-232906.256; 564,-226141.344;
          566,-227832.572; 568,-222275.68; 570,-227349.364; 572,-224933.324;
          574,-223725.304])                  "#1负荷"
      annotation (Placement(transformation(extent={{300,226},{320,246}})));
    Modelica.Blocks.Sources.RealExpression realExpression2(y=time/3600)
      annotation (Placement(transformation(extent={{322,202},{302,222}})));
    Modelica.Blocks.Sources.Constant const9(k=0.500000)
      annotation (Placement(transformation(extent={{296,288},{310,302}})));
    Pipe pipe20(Length=8, Diameter(displayUnit="mm") = 0.2)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={156,148})));
    User F7(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=3.23) "7栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={230,124})));
    Modelica.Blocks.Tables.CombiTable1Ds F7_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#7负荷"
      annotation (Placement(transformation(extent={{256,130},{236,150}})));
    Modelica.Blocks.Sources.RealExpression realExpression11(y=time/3600)
      annotation (Placement(transformation(extent={{284,130},{264,150}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible10(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={232,94})));

    Modelica.Blocks.Sources.Constant const10(k=0.595922)
      annotation (Placement(transformation(extent={{212,70},{226,84}})));
    Pipe pipe21(Length=36, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={190,122})));
    Pipe pipe22(Length=90, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={156,82})));
    Pipe pipe23(Length=36, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={192,50})));
    Pipe pipe24(Length=36, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={260,50})));
    Pipe pipe25(Length=12, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,10},{10,-10}},
          rotation=-90,
          origin={222,24})));
    User F9_2(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=3.23) "9栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={298,52})));
    Modelica.Blocks.Tables.CombiTable1Ds F9_2_load(table=[0,-280444; 1,-151431; 2,
          -159137; 3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655;
          9,-135341; 10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409;
          16,-120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621;
          22,-179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,
          -116862; 29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981;
          35,-80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#9负荷"
      annotation (Placement(transformation(extent={{324,58},{304,78}})));
    Modelica.Blocks.Sources.RealExpression realExpression12(y=time/3600)
      annotation (Placement(transformation(extent={{352,58},{332,78}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible12(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={300,26})));

    Modelica.Blocks.Sources.Constant const12(k=0.980507)
      annotation (Placement(transformation(extent={{282,2},{296,16}})));
    User F9_1(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=3.23) "9栋" annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=0,
          origin={196,4})));
    Modelica.Blocks.Tables.CombiTable1Ds F9_1_load(table=[0,-280444; 1,-151431; 2,
          -159137; 3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655;
          9,-135341; 10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409;
          16,-120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621;
          22,-179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,
          -116862; 29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981;
          35,-80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#9负荷"
      annotation (Placement(transformation(extent={{172,14},{192,34}})));
    Modelica.Blocks.Sources.RealExpression realExpression16(y=time/3600)
      annotation (Placement(transformation(extent={{142,14},{162,34}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible13(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=0,
          origin={198,-22})));

    Modelica.Blocks.Sources.Constant const13(k=0.988868)
      annotation (Placement(transformation(extent={{180,-46},{194,-32}})));

    Pipe pipe30(Length=20, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-88})));
    User F10(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=3.23) "10栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-58,-108})));
    Modelica.Blocks.Tables.CombiTable1Ds F10_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#10负荷"
      annotation (Placement(transformation(extent={{-32,-102},{-52,-82}})));
    Modelica.Blocks.Sources.RealExpression realExpression20(y=time/3600)
      annotation (Placement(transformation(extent={{-4,-102},{-24,-82}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible17(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-56,-138})));

    Modelica.Blocks.Sources.Constant const17(k=0.635664)
      annotation (Placement(transformation(extent={{-76,-164},{-62,-150}})));
    Pipe pipe31(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-98,-110})));
    Pipe pipe32(Length=20, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-150})));
    Pipe pipe33(Length=48, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-44,-184})));
    User F13(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=3.23) "13栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={158,-182})));
    Modelica.Blocks.Tables.CombiTable1Ds F13_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#13负荷"
      annotation (Placement(transformation(extent={{184,-176},{164,-156}})));
    Modelica.Blocks.Sources.RealExpression realExpression21(y=time/3600)
      annotation (Placement(transformation(extent={{218,-176},{198,-156}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible18(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={160,-212})));

    Modelica.Blocks.Sources.Constant const18(k=0.948706)
      annotation (Placement(transformation(extent={{140,-238},{154,-224}})));
    Pipe pipe34(Length=20, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-212})));
    Pipe pipe35(Length=6, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-94,-232})));
    User F12(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=3.23) "12栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-48,-230})));
    Modelica.Blocks.Tables.CombiTable1Ds F12_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#12负荷"
      annotation (Placement(transformation(extent={{-24,-224},{-44,-204}})));
    Modelica.Blocks.Sources.RealExpression realExpression22(y=time/3600)
      annotation (Placement(transformation(extent={{6,-224},{-14,-204}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible19(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-50,-262})));

    Modelica.Blocks.Sources.Constant const19(k=0.537505)
      annotation (Placement(transformation(extent={{-70,-288},{-56,-274}})));
    Pipe pipe36(Length=120, Diameter(displayUnit="mm") = 0.25)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-286})));
    Pipe pipe37(Length=12, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-184,-236})));
    User F11(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=3.23) "11栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-228,-258})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible20(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-230,-234})));

    Modelica.Blocks.Sources.Constant const20(k=0.500000)
      annotation (Placement(transformation(extent={{-254,-222},{-240,-208}})));
    Modelica.Blocks.Tables.CombiTable1Ds F11_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#11负荷"
      annotation (Placement(transformation(extent={{-254,-290},{-234,-270}})));
    Modelica.Blocks.Sources.RealExpression realExpression23(y=time/3600)
      annotation (Placement(transformation(extent={{-282,-290},{-262,-270}})));
    Pipe pipe38(Length=12, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-180,-322})));
    User F18(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=3.23) "18栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-244,-346})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible21(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-242,-320})));

    Modelica.Blocks.Sources.Constant const21(k=1.000000)
      annotation (Placement(transformation(extent={{-272,-310},{-258,-296}})));
    Modelica.Blocks.Tables.CombiTable1Ds F18_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#18负荷"
      annotation (Placement(transformation(extent={{-274,-380},{-254,-360}})));
    Modelica.Blocks.Sources.RealExpression realExpression24(y=time/3600)
      annotation (Placement(transformation(extent={{-250,-400},{-270,-380}})));
    Pipe pipe39(Length=60, Diameter(displayUnit="mm") = 0.2)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-348})));
    Pipe pipe40(Length=150, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={22,-374})));
    User F12_2(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=3.23) "12栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={66,-294})));
    Modelica.Blocks.Tables.CombiTable1Ds F12_2_load(table=[0,-280444; 1,-151431; 2,
          -159137; 3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655;
          9,-135341; 10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409;
          16,-120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621;
          22,-179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,
          -116862; 29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981;
          35,-80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#12负荷"
      annotation (Placement(transformation(extent={{92,-288},{72,-268}})));
    Modelica.Blocks.Sources.RealExpression realExpression25(y=time/3600)
      annotation (Placement(transformation(extent={{120,-288},{100,-268}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible22(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={90,-326})));

    Modelica.Blocks.Sources.Constant const22(k=0.531860)
      annotation (Placement(transformation(extent={{116,-352},{102,-338}})));
    Pipe pipe41(Length=150, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={154,-374})));
    Pipe pipe42(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={232,-350})));
    User F14(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=3.23) "14栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={198,-306})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible23(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={200,-282})));

    Modelica.Blocks.Tables.CombiTable1Ds F14oad(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#14负荷"
      annotation (Placement(transformation(extent={{170,-338},{190,-318}})));
    Modelica.Blocks.Sources.RealExpression realExpression26(y=time/3600)
      annotation (Placement(transformation(extent={{138,-338},{158,-318}})));
    Modelica.Blocks.Sources.Constant const23(k=0.638538)
      annotation (Placement(transformation(extent={{166,-274},{180,-260}})));
    Pipe pipe43(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,10},{10,-10}},
          rotation=-90,
          origin={232,-412})));
    User F15(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=3.23) "15栋" annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=0,
          origin={186,-432})));
    Modelica.Blocks.Tables.CombiTable1Ds F15_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#15负荷"
      annotation (Placement(transformation(extent={{160,-422},{180,-402}})));
    Modelica.Blocks.Sources.RealExpression realExpression27(y=time/3600)
      annotation (Placement(transformation(extent={{128,-422},{148,-402}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible24(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=0,
          origin={192,-458})));

    Modelica.Blocks.Sources.Constant const24(k=0.500000)
      annotation (Placement(transformation(extent={{162,-482},{176,-468}})));
    Pipe pipe44(Length=60, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=90,
          origin={-136,-434})));
    Pipe pipe45(Length=6, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-96,-468})));
    User F16(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=3.23) "16栋" annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-32,-466})));
    Modelica.Blocks.Tables.CombiTable1Ds F16_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#16负荷"
      annotation (Placement(transformation(extent={{2,-458},{-18,-438}})));
    Modelica.Blocks.Sources.RealExpression realExpression28(y=time/3600)
      annotation (Placement(transformation(extent={{30,-458},{10,-438}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible25(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-30,-498})));

    Modelica.Blocks.Sources.Constant const25(k=0.500000)
      annotation (Placement(transformation(extent={{2,-524},{-12,-510}})));
    Pipe pipe46(Length=12, Diameter(displayUnit="mm") = 0.125)
                "T1"
      annotation (Placement(transformation(extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-194,-472})));
    User F17(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=3.23) "17栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={-242,-496})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible26(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={-244,-470})));

    Modelica.Blocks.Sources.Constant const26(k=0.731250)
      annotation (Placement(transformation(extent={{-264,-460},{-250,-446}})));
    Modelica.Blocks.Tables.CombiTable1Ds F17_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#17负荷"
      annotation (Placement(transformation(extent={{-266,-532},{-246,-512}})));
    Modelica.Blocks.Sources.RealExpression realExpression29(y=time/3600)
      annotation (Placement(transformation(extent={{-244,-556},{-264,-536}})));
    Pipe pipe47(Length=72 + 66 + 132, Diameter(displayUnit="mm") = 0.15)
                "T1"
      annotation (Placement(transformation(extent={{10,-10},{-10,10}},
          rotation=0,
          origin={-260,-138})));
    User F19(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.1,
      mflow_start=3.23) "19栋" annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=0,
          origin={-364,-320})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible27(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,10},{10,-10}},
          rotation=0,
          origin={-360,-358})));

    Modelica.Blocks.Sources.Constant const27(k=0.835058)
      annotation (Placement(transformation(extent={{-392,-384},{-378,-370}})));
    Modelica.Blocks.Tables.CombiTable1Ds F19_load(table=[0,-280444; 1,-151431; 2,-159137;
          3,-138572; 4,-126893; 5,-131255; 6,-148447; 7,-131398; 8,-132655; 9,-135341;
          10,-123043; 11,-96005; 12,-75913; 13,-93915; 14,-131093; 15,-141409; 16,
          -120737; 17,-130144; 18,-123900; 19,-138719; 20,-144593; 21,-199621; 22,
          -179945; 23,-174376; 24,-176917; 25,-94285; 26,-127959; 27,-108961; 28,-116862;
          29,-111345; 30,-105792; 31,-98862; 32,-99574; 33,-102751; 34,-100981; 35,
          -80276; 36,-79807; 37,-75985; 38,-86512; 39,-83764; 40,-101016; 41,-94017;
          42,-78129; 43,-99061; 44,-110060; 45,-128403; 46,-118658; 47,-135445; 48,
          -129498; 49,-100905; 50,-87385; 51,-92113; 52,-80407; 53,-81115; 54,-80660;
          55,-79567; 56,-76347; 57,-80323; 58,-67869; 59,-68011; 60,-49041; 61,-51418;
          62,-65605; 63,-84762; 64,-91090; 65,-96455; 66,-107177; 67,-109104; 68,-106869;
          69,-111919; 70,-109155; 71,-110536; 72,-112412; 73,-83264; 74,-89796; 75,
          -106819; 76,-87058; 77,-91300; 78,-96443; 79,-85520; 80,-87034; 81,-84308;
          82,-97927; 83,-80299; 84,-67358; 85,-71548; 86,-39612; 87,-52204; 88,-80842;
          89,-157480; 90,-107639; 91,-141754; 92,-136863; 93,-142315; 94,-146898;
          95,-137170; 96,-126493; 97,-87377; 98,-91713; 99,-89250; 100,-103866; 101,
          -97538; 102,-94466; 103,-90872; 104,-95631; 105,-88682; 106,-68862; 107,
          -36899; 108,-13208; 109,-17657; 110,-11930; 111,-8308; 112,-17707; 113,-43993;
          114,-56302; 115,-62137; 116,-75355; 117,-99819; 118,-122548; 119,-102130;
          120,-126315; 121,-105638; 122,-88133; 123,-94470; 124,-92750; 125,-110913;
          126,-104462; 127,-100411; 128,-101776; 129,-88594; 130,-80665; 131,-64881;
          132,-45888; 133,-32160; 134,-26931; 135,-15081; 136,-25174; 137,-47518;
          138,-65463; 139,-82835; 140,-81666; 141,-107298; 142,-111656; 143,-117901;
          144,-106156; 145,-85835; 146,-103652; 147,-101213; 148,-90188; 149,-86792;
          150,-97236; 151,-111756; 152,-100256; 153,-103974; 154,-83747; 155,-70116;
          156,-69560; 157,-89325; 158,-63486; 159,-57098; 160,-66291; 161,-114392;
          162,-104087; 163,-116911; 164,-98576; 165,-134982; 166,-146054; 167,-141418;
          168,-157637; 169,-108350; 170,-107387; 171,-108404; 172,-118903; 173,-115724;
          174,-112277; 175,-120006; 176,-121413; 177,-119628; 178,-86848; 179,-95607;
          180,-91586; 181,-129795; 182,-91122; 183,-102346; 184,-108652; 185,-118519;
          186,-131322; 187,-133262; 188,-146514; 189,-167978; 190,-164742; 191,-163043;
          192,-152653; 193,-122700; 194,-113181; 195,-110904; 196,-118891; 197,-114518;
          198,-122307; 199,-113771; 200,-126790; 201,-109353; 202,-89210; 203,-71818;
          204,-59817; 205,-93438; 206,-76150; 207,-105624; 208,-107185; 209,-98292;
          210,-102015; 211,-125820; 212,-125666; 213,-154715; 214,-150741; 215,-153013;
          216,-153928; 217,-110104; 218,-106619; 219,-107372; 220,-101043; 221,-96636;
          222,-98991; 223,-102576; 224,-103339; 225,-97345; 226,-77706; 227,-69503;
          228,-73558; 229,-94200; 230,-106525; 231,-97063; 232,-108088; 233,-135937;
          234,-126356; 235,-118866; 236,-127445; 237,-154980; 238,-131026; 239,-127789;
          240,-147067; 241,-102175; 242,-112160; 243,-95972; 244,-94982; 245,-94863;
          246,-104397; 247,-93545; 248,-89186; 249,-91831; 250,-75785; 251,-80650;
          252,-61231; 253,-54802; 254,-88115; 255,-120187; 256,-123312; 257,-127199;
          258,-111807; 259,-149649; 260,-163609; 261,-154956; 262,-163137; 263,-167060;
          264,-134769; 265,-100186; 266,-106338; 267,-85663; 268,-90736; 269,-85381;
          270,-85365; 271,-78071; 272,-91282; 273,-74114; 274,-77475; 275,-56898;
          276,-54396; 277,-51401; 278,-38357; 279,-38408; 280,-42461; 281,-56843;
          282,-66891; 283,-87544; 284,-82132; 285,-92946; 286,-109354; 287,-97005;
          288,-104474; 289,-71270; 290,-65096; 291,-74869; 292,-73399; 293,-82662;
          294,-71215; 295,-81897; 296,-90117; 297,-65457; 298,-65384; 299,-60608;
          300,-53977; 301,-50263; 302,-46902; 303,-41780; 304,-49198; 305,-61637;
          306,-65598; 307,-84972; 308,-95758; 309,-102944; 310,-108046; 311,-99893;
          312,-108316; 313,-86767; 314,-78044; 315,-67916; 316,-73924; 317,-82492;
          318,-71620; 319,-67443; 320,-66092; 321,-71458; 322,-66415; 323,-71175;
          324,-58875; 325,-46363; 326,-48230; 327,-47735; 328,-59083; 329,-69384;
          330,-68533; 331,-92461; 332,-78895; 333,-96658; 334,-99386; 335,-108222;
          336,-118455; 337,-82222; 338,-76613; 339,-77840; 340,-79976; 341,-86142;
          342,-82582; 343,-75776; 344,-80457; 345,-86613; 346,-85621; 347,-74443;
          348,-65206; 349,-82065; 350,-76957; 351,-90752; 352,-75863; 353,-88065;
          354,-73586; 355,-97807; 356,-97249; 357,-135667; 358,-117347; 359,-116566;
          360,-116828; 361,-113776; 362,-93494; 363,-89509; 364,-87199; 365,-86435;
          366,-89692; 367,-96334; 368,-90769; 369,-96170; 370,-79411; 371,-77313;
          372,-43124; 373,-41490; 374,-87590; 375,-74124; 376,-106945; 377,-112150;
          378,-94957; 379,-114374; 380,-103447; 381,-145947; 382,-133654; 383,-135285;
          384,-137011; 385,-98374; 386,-99807; 387,-92365; 388,-91421; 389,-97845;
          390,-93027; 391,-86847; 392,-81053; 393,-81428; 394,-73540; 395,-76134;
          396,-77010; 397,-91461; 398,-89651; 399,-95637; 400,-102976; 401,-108349;
          402,-96754; 403,-149385; 404,-130520; 405,-139574; 406,-142760; 407,-114833;
          408,-131000; 409,-83677; 410,-87619; 411,-96209; 412,-92752; 413,-83288;
          414,-82550; 415,-81229; 416,-79271; 417,-86175; 418,-65596; 419,-62780;
          420,-62157; 421,-68198; 422,-75427; 423,-79261; 424,-77445; 425,-97934;
          426,-95026; 427,-139520; 428,-119130; 429,-117004; 430,-124245; 431,-115577;
          432,-129953; 433,-82392; 434,-86863; 435,-85770; 436,-81600; 437,-78418;
          438,-81866; 439,-65619; 440,-85011; 441,-72226; 442,-56509; 443,-40173;
          444,-27890; 445,-13286; 446,-11303; 447,-13864; 448,-17051; 449,-42861;
          450,-64535; 451,-104573; 452,-70157; 453,-189623; 454,-169079; 455,-131959;
          456,-105277; 457,-71971; 458,-79606; 459,-78707; 460,-74894; 461,-71905;
          462,-75122; 463,-60376; 464,-78389; 465,-70044; 466,-57017; 467,-43037;
          468,-25714; 469,-8042; 470,-5330; 471,-5629; 472,-11510; 473,-23598; 474,
          -49721; 475,-90272; 476,-58293; 477,-159701; 478,-144809; 479,-114512; 480,
          -116617; 481,-92205; 482,-107165; 483,-101483; 484,-103600; 485,-98027;
          486,-108565; 487,-107131; 488,-103451; 489,-96735; 490,-81687; 491,-62193;
          492,-40606; 493,-21595; 494,-20091; 495,-14232; 496,-20121; 497,-45396;
          498,-77697; 499,-67478; 500,-67753; 501,-103416; 502,-101745; 503,-108456;
          504,-112664; 505,-93244; 506,-93734; 507,-102365; 508,-102575; 509,-109037;
          510,-100172; 511,-97928; 512,-111487; 513,-103869; 514,-94163; 515,-65218])
      "#19负荷"
      annotation (Placement(transformation(extent={{-404,-314},{-384,-294}})));
    Modelica.Blocks.Sources.RealExpression realExpression3(y=time/3600)
      annotation (Placement(transformation(extent={{-448,-314},{-428,-294}})));
    Modelica.Fluid.Sensors.Temperature temperature8(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-144,210},{-164,230}})));
    Modelica.Fluid.Sensors.Pressure pressure7(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-148,202},{-168,182}})));
    Modelica.Fluid.Sensors.Temperature temperature9(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-106,64},{-126,44}})));
    Modelica.Fluid.Sensors.Pressure pressure8(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-82,62},{-102,42}})));
    Modelica.Fluid.Sensors.Temperature temperature10(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-60,212},{-80,232}})));
    Modelica.Fluid.Sensors.Pressure pressure9(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-64,204},{-84,184}})));
    Modelica.Fluid.Sensors.Temperature temperature11(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{34,214},{14,234}})));
    Modelica.Fluid.Sensors.Pressure pressure10(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{30,206},{10,186}})));
    Modelica.Fluid.Sensors.Temperature temperature12(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{114,214},{94,234}})));
    Modelica.Fluid.Sensors.Pressure pressure11(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{110,206},{90,186}})));
    Modelica.Fluid.Sensors.Temperature temperature14(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{342,212},{322,232}})));
    Modelica.Fluid.Sensors.Pressure pressure13(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{338,204},{318,184}})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate3(redeclare package
        Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater) annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={-130,254})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate4(redeclare package
        Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater) annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={-46,256})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate5(redeclare package
        Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater) annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={46,258})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate6(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={128,264})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate8(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={356,264})));
    Modelica.Fluid.Sensors.Temperature temperature15(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-160,272},{-140,292}})));
    Modelica.Fluid.Sensors.Pressure pressure14(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-142,274},{-122,294}})));
    Modelica.Fluid.Sensors.Temperature temperature16(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-74,282},{-54,302}})));
    Modelica.Fluid.Sensors.Pressure pressure15(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-56,284},{-36,304}})));
    Modelica.Fluid.Sensors.Temperature temperature17(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{14,278},{34,298}})));
    Modelica.Fluid.Sensors.Pressure pressure16(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{32,280},{52,300}})));
    Modelica.Fluid.Sensors.Temperature temperature18(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{100,286},{120,306}})));
    Modelica.Fluid.Sensors.Pressure pressure17(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{118,288},{138,308}})));
    Modelica.Fluid.Sensors.Temperature temperature20(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{328,288},{348,308}})));
    Modelica.Fluid.Sensors.Pressure pressure19(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{346,290},{366,310}})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate9(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={-26,80})));
    Modelica.Fluid.Sensors.Temperature temperature21(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-76,112},{-96,132}})));
    Modelica.Fluid.Sensors.Pressure pressure20(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-58,106},{-78,126}})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate10(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={264,108})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate11(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={-20,-18})));
    Modelica.Fluid.Sensors.Temperature temperature22(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-94,-46},{-114,-66}})));
    Modelica.Fluid.Sensors.Pressure pressure21(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-72,-42},{-92,-62}})));
    Modelica.Fluid.Sensors.Temperature temperature23(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-184,90},{-204,110}})));
    Modelica.Fluid.Sensors.Pressure pressure22(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-234,88},{-254,108}})));
    Modelica.Fluid.Sensors.Temperature temperature24(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-180,36},{-200,16}})));
    Modelica.Fluid.Sensors.Pressure pressure23(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-158,34},{-178,14}})));
    Modelica.Fluid.Sensors.Temperature temperature25(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-88,6},{-108,26}})));
    Modelica.Fluid.Sensors.Pressure pressure24(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-68,6},{-88,26}})));
    Modelica.Fluid.Sensors.Temperature temperature26(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-78,-102},{-98,-82}})));
    Modelica.Fluid.Sensors.Pressure pressure25(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-60,-102},{-80,-82}})));
    Modelica.Fluid.Sensors.Temperature temperature27(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-104,-140},{-124,-160}})));
    Modelica.Fluid.Sensors.Pressure pressure26(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-82,-136},{-102,-156}})));
    Modelica.Fluid.Sensors.Temperature temperature28(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-100,-268},{-120,-288}})));
    Modelica.Fluid.Sensors.Pressure pressure27(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-78,-264},{-98,-284}})));
    Modelica.Fluid.Sensors.Temperature temperature29(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{108,-220},{88,-240}})));
    Modelica.Fluid.Sensors.Pressure pressure28(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{130,-216},{110,-236}})));
    Modelica.Fluid.Sensors.Temperature temperature30(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{16,-306},{-4,-326}})));
    Modelica.Fluid.Sensors.Pressure pressure29(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{38,-302},{18,-322}})));
    Modelica.Fluid.Sensors.Temperature temperature31(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{62,-338},{42,-358}})));
    Modelica.Fluid.Sensors.Pressure pressure30(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{84,-334},{64,-354}})));
    Modelica.Fluid.Sensors.Temperature temperature32(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{212,-340},{192,-360}})));
    Modelica.Fluid.Sensors.Pressure pressure31(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{230,-332},{210,-352}})));
    Modelica.Fluid.Sensors.Temperature temperature33(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{260,-288},{240,-308}})));
    Modelica.Fluid.Sensors.Pressure pressure32(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{282,-284},{262,-304}})));
    Modelica.Fluid.Sensors.Temperature temperature34(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{226,-474},{206,-494}})));
    Modelica.Fluid.Sensors.Pressure pressure33(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{244,-466},{224,-486}})));
    Modelica.Fluid.Sensors.Temperature temperature35(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{206,-414},{186,-394}})));
    Modelica.Fluid.Sensors.Pressure pressure34(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{228,-410},{208,-390}})));
    Modelica.Fluid.Sensors.Temperature temperature36(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-68,-454},{-88,-434}})));
    Modelica.Fluid.Sensors.Pressure pressure35(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-42,-456},{-62,-436}})));
    Modelica.Fluid.Sensors.Temperature temperature37(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-66,-510},{-86,-530}})));
    Modelica.Fluid.Sensors.Pressure pressure36(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-40,-506},{-60,-526}})));
    Modelica.Fluid.Sensors.Temperature temperature38(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-74,-216},{-94,-196}})));
    Modelica.Fluid.Sensors.Pressure pressure37(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-54,-218},{-74,-198}})));
    Modelica.Fluid.Sensors.Temperature temperature39(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{128,-172},{108,-152}})));
    Modelica.Fluid.Sensors.Pressure pressure38(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{148,-174},{128,-154}})));
    Modelica.Fluid.Sensors.Temperature temperature40(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-208,-506},{-228,-526}})));
    Modelica.Fluid.Sensors.Pressure pressure39(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-182,-502},{-202,-522}})));
    Modelica.Fluid.Sensors.Temperature temperature41(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-222,-452},{-242,-432}})));
    Modelica.Fluid.Sensors.Pressure pressure40(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-198,-454},{-218,-434}})));
    Modelica.Fluid.Sensors.Temperature temperature42(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-206,-218},{-226,-198}})));
    Modelica.Fluid.Sensors.Pressure pressure41(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-186,-230},{-206,-210}})));
    Modelica.Fluid.Sensors.Temperature temperature43(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-198,-264},{-218,-284}})));
    Modelica.Fluid.Sensors.Pressure pressure42(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-176,-260},{-196,-280}})));
    Modelica.Fluid.Sensors.Temperature temperature44(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-214,-316},{-234,-296}})));
    Modelica.Fluid.Sensors.Pressure pressure43(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-192,-318},{-212,-298}})));
    Modelica.Fluid.Sensors.Temperature temperature45(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-212,-356},{-232,-376}})));
    Modelica.Fluid.Sensors.Pressure pressure44(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-186,-352},{-206,-372}})));
    Modelica.Fluid.Sensors.Temperature temperature46(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-326,-372},{-346,-392}})));
    Modelica.Fluid.Sensors.Pressure pressure45(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-300,-368},{-320,-388}})));
    Modelica.Fluid.Sensors.Temperature temperature47(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-340,-310},{-360,-290}})));
    Modelica.Fluid.Sensors.Pressure pressure46(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{-318,-314},{-338,-294}})));
    Pipe pipe48(Length=12, Diameter(displayUnit="mm") = 0.1)
                "T1"
      annotation (Placement(transformation(extent={{-10,-10},{10,10}},
          rotation=90,
          origin={232,198})));
    User F2(
      Length=5.734,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=5.78) "2栋" annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={216,256})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible11(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.linear)
      annotation (Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=0,
          origin={214,280})));
    Modelica.Blocks.Tables.CombiTable1Ds F2_2oad(table=[0,-208021.044; 2,-212369.916;
          4,-215027.56; 6,-219134.828; 8,-218168.412; 10,-219134.828; 12,-222517.284;
          14,-205121.796; 16,-197390.468; 18,-191350.368; 20,-181203; 22,-184827.06;
          24,-207537.836; 26,-223000.492; 28,-209953.876; 30,-212853.124; 32,-196424.052;
          34,-208021.044; 36,-201497.736; 38,-200048.112; 40,-195699.24; 42,-184102.248;
          44,-185793.476; 46,-196182.448; 48,-197390.468; 50,-197148.864; 52,-198115.28;
          54,-198356.884; 56,-200048.112; 58,-207537.836; 60,-205605.004; 62,-204155.38;
          64,-200772.924; 66,-197148.864; 68,-206813.024; 70,-206088.212; 72,-204155.38;
          74,-210678.688; 76,-206329.816; 78,-206813.024; 80,-205121.796; 82,-197632.072;
          84,-188692.724; 86,-198115.28; 88,-197390.468; 90,-191350.368; 92,-190625.556;
          94,-194491.22; 96,-191591.972; 98,-196182.448; 100,-197873.676; 102,-198840.092;
          104,-222275.68; 106,-215269.164; 108,-216718.788; 110,-198598.488;
          112,-193283.2; 114,-192558.388; 116,-197390.468; 118,-196424.052; 120,
          -194249.616; 122,-195457.636; 124,-197632.072; 126,-193283.2; 128,-187243.1;
          130,-171780.444; 132,-173471.672; 134,-159700.244; 136,-169122.8; 138,
          -169606.008; 140,-164049.116; 142,-166223.552; 144,-162116.284; 146,-167431.572;
          148,-168156.384; 150,-167914.78; 152,-167914.78; 154,-153418.54; 156,
          -138680.696; 158,-126117.288; 160,-133365.408; 162,-154868.164; 164,-137714.28;
          166,-133123.804; 168,-138439.092; 170,-139888.716; 172,-138439.092;
          174,-136506.26; 176,-146653.628; 178,-155109.768; 180,-126117.288;
          182,-121043.604; 184,-132882.2; 186,-126842.1; 188,-132157.388; 190,-127083.704;
          192,-134815.032; 194,-127808.516; 196,-128533.328; 198,-131915.784;
          200,-135298.24; 202,-152452.124; 204,-155351.372; 206,-155351.372;
          208,-166465.156; 210,-171297.236; 212,-179994.98; 214,-185793.476;
          216,-184343.852; 218,-184585.456; 220,-181444.604; 222,-190867.16;
          224,-206813.024; 226,-209229.064; 228,-208987.46; 230,-202222.548;
          232,-213819.54; 234,-220342.848; 236,-216235.58; 238,-221309.264; 240,
          -218168.412; 242,-218893.224; 244,-221309.264; 246,-216235.58; 248,-206571.42;
          250,-218651.62; 252,-213577.936; 254,-206813.024; 256,-205846.608;
          258,-219859.64; 260,-208262.648; 262,-210195.48; 264,-203913.776; 266,
          -216235.58; 268,-208021.044; 270,-217685.204; 272,-208262.648; 274,-210437.084;
          276,-206813.024; 278,-194974.428; 280,-203913.776; 282,-196424.052;
          284,-194008.012; 286,-196424.052; 288,-201497.736; 290,-200289.716;
          292,-198356.884; 294,-198840.092; 296,-200048.112; 298,-201980.944;
          300,-191833.576; 302,-193766.408; 304,-193041.596; 306,-192558.388;
          308,-195216.032; 310,-196907.26; 312,-193283.2; 314,-193524.804; 316,
          -195699.24; 318,-198840.092; 320,-200048.112; 322,-194008.012; 324,-194732.824;
          326,-197873.676; 328,-188692.724; 330,-187001.496; 332,-187243.1; 334,
          -188209.516; 336,-188209.516; 338,-186759.892; 340,-186276.684; 342,-188209.516;
          344,-195699.24; 346,-189659.14; 348,-191591.972; 350,-187484.704; 352,
          -207054.628; 354,-204396.984; 356,-210195.48; 358,-200531.32; 360,-204155.38;
          362,-205363.4; 364,-205121.796; 366,-208262.648; 368,-208745.856; 370,
          -210678.688; 372,-212369.916; 374,-220826.056; 376,-230731.82; 378,-245469.664;
          380,-236288.712; 382,-237979.94; 384,-236288.712; 386,-239429.564;
          388,-236530.316; 390,-240395.98; 392,-241362.396; 394,-244986.456;
          396,-241845.604; 398,-240879.188; 400,-238946.356; 402,-240879.188;
          404,-241120.792; 406,-239671.168; 408,-239671.168; 410,-241362.396;
          412,-245228.06; 414,-242328.812; 416,-250543.348; 418,-256100.24; 420,
          -251992.972; 422,-248852.12; 424,-240395.98; 426,-245952.872; 428,-251509.764;
          430,-250543.348; 432,-253684.2; 434,-250301.744; 436,-252717.784; 438,
          -253442.596; 440,-256341.844; 442,-255133.824; 444,-255858.636; 446,-257066.656;
          448,-254892.22; 450,-257308.26; 452,-266247.608; 454,-261415.528; 456,
          -262865.152; 458,-266006.004; 460,-262381.944; 462,-264073.172; 464,-265039.588;
          466,-254167.408; 468,-246677.684; 470,-240637.584; 472,-248127.308;
          474,-248127.308; 476,-247402.496; 478,-247160.892; 480,-248852.12;
          482,-247160.892; 484,-247885.704; 486,-248852.12; 488,-248127.308;
          490,-247644.1; 492,-238463.148; 494,-238704.752; 496,-239671.168; 498,
          -237013.524; 500,-232664.652; 502,-234597.484; 504,-235080.692; 506,-237496.732;
          508,-239187.96; 510,-241604; 512,-239187.96; 514,-240879.188; 516,-234355.88;
          518,-232906.256; 520,-234839.088; 522,-235080.692; 524,-238946.356;
          526,-238221.544; 528,-236530.316; 530,-237979.94; 532,-240154.376;
          534,-239671.168; 536,-238221.544; 538,-232664.652; 540,-237979.94;
          542,-231698.236; 544,-237496.732; 546,-232906.256; 548,-233631.068;
          550,-234355.88; 552,-238221.544; 554,-235080.692; 556,-238704.752;
          558,-235080.692; 560,-236047.108; 562,-232906.256; 564,-226141.344;
          566,-227832.572; 568,-222275.68; 570,-227349.364; 572,-224933.324;
          574,-223725.304]) "#2负荷"
      annotation (Placement(transformation(extent={{190,226},{210,246}})));
    Modelica.Blocks.Sources.RealExpression realExpression14(y=time/3600)
      annotation (Placement(transformation(extent={{212,204},{192,224}})));
    Modelica.Blocks.Sources.Constant const11(k=1.000000)
      annotation (Placement(transformation(extent={{186,290},{200,304}})));
    Modelica.Fluid.Sensors.Temperature temperature48(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{232,214},{212,234}})));
    Modelica.Fluid.Sensors.Pressure pressure47(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{228,206},{208,186}})));
    Modelica.Fluid.Sensors.VolumeFlowRate volumeFlowRate12(redeclare package
        Medium = Modelica.Media.Water.ConstantPropertyLiquidWater)
                                                            annotation (Placement(
          transformation(
          extent={{-10,-10},{10,10}},
          rotation=-90,
          origin={246,266})));
    Modelica.Fluid.Sensors.Temperature temperature49(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{218,290},{238,310}})));
    Modelica.Fluid.Sensors.Pressure pressure48(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{236,292},{256,312}})));
    Modelica.Fluid.Machines.ControlledPump pump1(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      p_b_start=400000,
      m_flow_start=44,
      N_nominal(displayUnit="rpm"),
      T_start=313.15,
      p_a_nominal=300000,
      p_b_nominal=600000,
      m_flow_nominal=400/3600*1000,
      use_m_flow_set=false)
                           "循环泵"
      annotation (Placement(transformation(extent={{-390,-72},{-370,-52}})));
  equation
    connect(pump.port_b, pressure.port) annotation (Line(points={{-370,-32},{
            -258,-32},{-258,-28}},
                           color={0,127,255}));
    connect(mflow.u, realExpression15.y)
      annotation (Line(points={{-360,2},{-347,2}}, color={0,0,127}));
    connect(pipe.port_b1, boundary1.ports[1]) annotation (Line(points={{-248,-36},
            {-274,-36},{-274,-70},{-329,-70}},
                                color={0,127,255}));
    connect(pump.port_a, boundary.ports[1])
      annotation (Line(points={{-390,-32},{-404,-32},{-404,-31},{-416,-31}},
                                                   color={0,127,255}));
    connect(Tg.u,realExpression13. y)
      annotation (Line(points={{-470,-36},{-481,-36}},
                                                   color={0,0,127}));
    connect(Tg.y[1], boundary.T_in)
      annotation (Line(points={{-447,-36},{-438,-36}},
                                                   color={0,0,127}));
    connect(temperature.port, boundary1.ports[2])
      annotation (Line(points={{-266,-70},{-327,-70}}, color={0,127,255}));
    connect(pump.port_b, pipe.port_a)
      annotation (Line(points={{-370,-32},{-248,-32}}, color={0,127,255}));
    connect(pipe.port_b, pipe1.port_a) annotation (Line(points={{-228,-32},{-220,-32},
            {-220,-12},{-192,-12}}, color={0,127,255}));
    connect(pipe.port_a1, pipe1.port_b1) annotation (Line(points={{-228,-36},{-216,
            -36},{-216,-16},{-192,-16}}, color={0,127,255}));
    connect(pipe.port_b, pipe2.port_a) annotation (Line(points={{-228,-32},{-220,-32},
            {-220,-52},{-190,-52}}, color={0,127,255}));
    connect(pipe.port_a1, pipe2.port_b1) annotation (Line(points={{-228,-36},{-216,
            -36},{-216,-56},{-190,-56}}, color={0,127,255}));
    connect(pipe1.port_b, pipe3.port_a) annotation (Line(points={{-172,-12},{-154,
            -12},{-154,6}}, color={0,127,255}));
    connect(pipe1.port_a1, pipe3.port_b1) annotation (Line(points={{-172,-16},{-150,
            -16},{-150,6}}, color={0,127,255}));
    connect(pipe2.port_b, pipe4.port_a) annotation (Line(points={{-170,-52},{-138,
            -52},{-138,-32}}, color={0,127,255}));
    connect(pipe2.port_a1, pipe4.port_b1) annotation (Line(points={{-170,-56},{-134,
            -56},{-134,-32}}, color={0,127,255}));
    connect(pipe4.port_a1, pipe5.port_b1)
      annotation (Line(points={{-134,-12},{-134,130}}, color={0,127,255}));
    connect(pipe4.port_b, pipe5.port_a)
      annotation (Line(points={{-138,-12},{-138,130}}, color={0,127,255}));
    connect(realExpression8.y, F8_load.u)
      annotation (Line(points={{-29,14},{-34,14}}, color={0,0,127}));
    connect(F8_load.y[1], F8.Q)
      annotation (Line(points={{-57,14},{-62,14},{-62,4}}, color={0,0,127}));
    connect(const4.y, valveIncompressible4.opening) annotation (Line(points={{-50.7,
            -53},{-60,-53},{-60,-44}}, color={0,0,127}));
    connect(F5.port_b, valveIncompressible1.port_a) annotation (Line(points={{-214,
            48},{-236,48},{-236,70},{-218,70}}, color={0,127,255}));
    connect(realExpression1.y, F5_load1.u)
      annotation (Line(points={{-235,28},{-230,28}}, color={0,0,127}));
    connect(F5_load1.y[1], F5.Q)
      annotation (Line(points={{-207,28},{-204,28},{-204,42}}, color={0,0,127}));
    connect(const1.y, valveIncompressible1.opening) annotation (Line(points={{-217.3,
            87},{-208,87},{-208,78}}, color={0,0,127}));
    connect(pipe4.port_b, pipe6.port_a) annotation (Line(points={{-138,-12},{-138,
            -2},{-112,-2}}, color={0,127,255}));
    connect(pipe6.port_b1, pipe5.port_b1) annotation (Line(points={{-112,-6},{-134,
            -6},{-134,130}}, color={0,127,255}));
    connect(pipe6.port_b, F8.port_a)
      annotation (Line(points={{-92,-2},{-72,-2}}, color={0,127,255}));
    connect(pipe6.port_a1, valveIncompressible4.port_b) annotation (Line(points={{-92,-6},
            {-80,-6},{-80,-36},{-70,-36}},         color={0,127,255}));
    connect(valveIncompressible1.port_b, pipe7.port_a1) annotation (Line(points={{
            -198,70},{-186,70},{-186,52},{-180,52}}, color={0,127,255}));
    connect(pipe7.port_b1, pipe3.port_a1) annotation (Line(points={{-160,52},{-150,
            52},{-150,26}}, color={0,127,255}));
    connect(pipe7.port_a, pipe3.port_b) annotation (Line(points={{-160,48},{-154,48},
            {-154,26}}, color={0,127,255}));
    connect(F5.port_a, pipe7.port_b)
      annotation (Line(points={{-194,48},{-180,48}}, color={0,127,255}));
    connect(pipe8.port_a, pipe3.port_b)
      annotation (Line(points={{-154,62},{-154,26}}, color={0,127,255}));
    connect(pipe8.port_b1, pipe3.port_a1)
      annotation (Line(points={{-150,62},{-150,26}}, color={0,127,255}));
    connect(realExpression4.y, F6_load.u)
      annotation (Line(points={{-17,120},{-22,120}}, color={0,0,127}));
    connect(F6_load.y[1], F6.Q)
      annotation (Line(points={{-45,120},{-52,120},{-52,102}}, color={0,0,127}));
    connect(const2.y, valveIncompressible2.opening) annotation (Line(points={{-60.7,
            47},{-64,47},{-64,58}},            color={0,0,127}));
    connect(pipe9.port_b, F6.port_a)
      annotation (Line(points={{-96,96},{-62,96}}, color={0,127,255}));
    connect(pipe9.port_a1, valveIncompressible2.port_b) annotation (Line(points={{
            -96,92},{-84,92},{-84,66},{-74,66}}, color={0,127,255}));
    connect(pipe8.port_a1, pipe9.port_b1) annotation (Line(points={{-150,82},{-150,
            92},{-116,92}}, color={0,127,255}));
    connect(pipe8.port_b, pipe9.port_a) annotation (Line(points={{-154,82},{-154,96},
            {-116,96}}, color={0,127,255}));
    connect(pipe10.port_b1, pipe9.port_b1) annotation (Line(points={{-150,110},{-150,
            92},{-116,92}}, color={0,127,255}));
    connect(pipe10.port_a, pipe8.port_b)
      annotation (Line(points={{-154,110},{-154,82}}, color={0,127,255}));
    connect(pipe10.port_b, pipe11.port_a) annotation (Line(points={{-154,130},{
            -154,178},{-144,178},{-144,184}},
                                         color={0,127,255}));
    connect(pipe10.port_b, pipe12.port_a) annotation (Line(points={{-154,130},{
            -154,178},{-62,178},{-62,184}},
                                       color={0,127,255}));
    connect(pipe11.port_b1, pipe10.port_a1) annotation (Line(points={{-140,184},
            {-140,174},{-150,174},{-150,130}},
                                         color={0,127,255}));
    connect(pipe12.port_b1, pipe10.port_a1) annotation (Line(points={{-58,184},
            {-58,174},{-150,174},{-150,130}},
                                         color={0,127,255}));
    connect(F4_1.port_a, pipe11.port_b) annotation (Line(points={{-154,244},{
            -144,244},{-144,204}},
                              color={0,127,255}));
    connect(valveIncompressible3.port_a, F4_1.port_b) annotation (Line(points={{-176,
            268},{-192,268},{-192,244},{-174,244}}, color={0,127,255}));
    connect(realExpression5.y, F4_1_load.u) annotation (Line(points={{-211,206},
            {-211,217},{-212,217},{-212,228}},
                                         color={0,0,127}));
    connect(F4_1_load.y[1], F4_1.Q) annotation (Line(points={{-189,228},{-176,
            228},{-176,238},{-164,238}},
                                    color={0,0,127}));
    connect(const3.y, valveIncompressible3.opening) annotation (Line(points={{-179.3,
            285},{-166,285},{-166,276}}, color={0,0,127}));
    connect(realExpression6.y, F4_1_load1.u) annotation (Line(points={{-101,210},
            {-106,210},{-106,232},{-104,232}},color={0,0,127}));
    connect(F4_1_load1.y[1], F4_2.Q)
      annotation (Line(points={{-81,232},{-76,232},{-76,246}}, color={0,0,127}));
    connect(const5.y, valveIncompressible5.opening) annotation (Line(points={{-79.3,
            297},{-78,297},{-78,284}},           color={0,0,127}));
    connect(valveIncompressible5.port_a, F4_2.port_b) annotation (Line(points={{-88,276},
            {-94,276},{-94,252},{-86,252}},        color={0,127,255}));
    connect(F4_2.port_a, pipe12.port_b) annotation (Line(points={{-66,252},{-62,
            252},{-62,204}},
                        color={0,127,255}));
    connect(pipe13.port_b1, pipe10.port_a1) annotation (Line(points={{-36,174},{-150,
            174},{-150,130}}, color={0,127,255}));
    connect(pipe10.port_b, pipe13.port_a) annotation (Line(points={{-154,130},{-154,
            178},{-36,178}}, color={0,127,255}));
    connect(F3_1.port_a, pipe14.port_b)
      annotation (Line(points={{24,248},{34,248},{34,208}},color={0,127,255}));
    connect(F3_1_load.y[1], F3_1.Q)
      annotation (Line(points={{11,228},{14,228},{14,242}}, color={0,0,127}));
    connect(const6.y, valveIncompressible6.opening)
      annotation (Line(points={{-1.3,289},{12,289},{12,280}},  color={0,0,127}));
    connect(F3_2_load.y[1], F3_2.Q)
      annotation (Line(points={{93,236},{98,236},{98,250}}, color={0,0,127}));
    connect(const7.y, valveIncompressible7.opening)
      annotation (Line(points={{90.7,297},{96,297},{96,288}}, color={0,0,127}));
    connect(F3_2.port_a, pipe15.port_b)
      annotation (Line(points={{108,256},{112,256},{112,208}},
                                                            color={0,127,255}));
    connect(F3_1_load.u, realExpression7.y) annotation (Line(points={{-12,228},
            {-18,228},{-18,206},{-11,206}},
                                       color={0,0,127}));
    connect(F3_2_load.u, realExpression9.y) annotation (Line(points={{70,236},{
            64,236},{64,214},{73,214}}, color={0,0,127}));
    connect(valveIncompressible6.port_a, F3_1.port_b) annotation (Line(points={{2,272},
            {-2,272},{-2,248},{4,248}},          color={0,127,255}));
    connect(valveIncompressible7.port_a, F3_2.port_b) annotation (Line(points={{86,280},
            {84,280},{84,256},{88,256}},      color={0,127,255}));
    connect(pipe13.port_b, pipe15.port_a)
      annotation (Line(points={{-16,178},{112,178},{112,188}},
                                                             color={0,127,255}));
    connect(pipe15.port_b1, pipe13.port_a1)
      annotation (Line(points={{116,188},{116,174},{-16,174}},
                                                             color={0,127,255}));
    connect(pipe14.port_a, pipe15.port_a) annotation (Line(points={{34,188},{34,
            178},{112,178},{112,188}},
                                color={0,127,255}));
    connect(pipe14.port_b1, pipe13.port_a1)
      annotation (Line(points={{38,188},{38,174},{-16,174}}, color={0,127,255}));
    connect(pipe13.port_b, pipe16.port_a)
      annotation (Line(points={{-16,178},{128,178}}, color={0,127,255}));
    connect(pipe16.port_b1, pipe13.port_a1)
      annotation (Line(points={{128,174},{-16,174}}, color={0,127,255}));
    connect(pipe16.port_b, pipe18.port_a)
      annotation (Line(points={{148,178},{260,178}}, color={0,127,255}));
    connect(pipe18.port_b1, pipe16.port_a1)
      annotation (Line(points={{260,174},{148,174}}, color={0,127,255}));
    connect(F1oad.y[1], F1.Q) annotation (Line(points={{321,236},{326,236},{326,
            248}}, color={0,0,127}));
    connect(const9.y, valveIncompressible9.opening) annotation (Line(points={{310.7,
            295},{324,295},{324,286}}, color={0,0,127}));
    connect(F1.port_a, pipe19.port_b) annotation (Line(points={{336,254},{340,
            254},{340,206}},
                        color={0,127,255}));
    connect(F1oad.u, realExpression2.y) annotation (Line(points={{298,236},{294,
            236},{294,212},{301,212}}, color={0,0,127}));
    connect(valveIncompressible9.port_a,F1. port_b) annotation (Line(points={{314,278},
            {314,264},{316,264},{316,254}},      color={0,127,255}));
    connect(pipe18.port_b, pipe19.port_a) annotation (Line(points={{280,178},{
            340,178},{340,186}},
                             color={0,127,255}));
    connect(pipe18.port_a1, pipe19.port_b1) annotation (Line(points={{280,174},
            {344,174},{344,186}},
                             color={0,127,255}));
    connect(pipe20.port_b1, pipe16.port_a1) annotation (Line(points={{154,158},
            {154,174},{148,174}},
                             color={0,127,255}));
    connect(pipe20.port_a, pipe16.port_b) annotation (Line(points={{158,158},{
            158,178},{148,178}},
                             color={0,127,255}));
    connect(realExpression11.y, F7_load.u)
      annotation (Line(points={{263,140},{258,140}}, color={0,0,127}));
    connect(F7_load.y[1], F7.Q)
      annotation (Line(points={{235,140},{230,140},{230,130}}, color={0,0,127}));
    connect(const10.y, valveIncompressible10.opening) annotation (Line(points={{226.7,
            77},{226.7,80},{232,80},{232,86}}, color={0,0,127}));
    connect(pipe21.port_b, F7.port_a)
      annotation (Line(points={{200,124},{220,124}}, color={0,127,255}));
    connect(pipe21.port_a1, valveIncompressible10.port_b) annotation (Line(points
          ={{200,120},{212,120},{212,94},{222,94}}, color={0,127,255}));
    connect(pipe20.port_b, pipe21.port_a) annotation (Line(points={{158,138},{158,
            124},{180,124}}, color={0,127,255}));
    connect(pipe20.port_a1, pipe21.port_b1) annotation (Line(points={{154,138},{154,
            120},{180,120}}, color={0,127,255}));
    connect(pipe20.port_b, pipe22.port_a)
      annotation (Line(points={{158,138},{158,92}}, color={0,127,255}));
    connect(pipe20.port_a1, pipe22.port_b1)
      annotation (Line(points={{154,138},{154,92}}, color={0,127,255}));
    connect(pipe22.port_b, pipe23.port_a)
      annotation (Line(points={{158,72},{158,52},{182,52}}, color={0,127,255}));
    connect(pipe22.port_a1, pipe23.port_b1)
      annotation (Line(points={{154,72},{154,48},{182,48}}, color={0,127,255}));
    connect(pipe23.port_b, pipe24.port_a)
      annotation (Line(points={{202,52},{250,52}}, color={0,127,255}));
    connect(pipe23.port_a1, pipe24.port_b1)
      annotation (Line(points={{202,48},{250,48}}, color={0,127,255}));
    connect(pipe25.port_b1, pipe24.port_b1)
      annotation (Line(points={{224,34},{224,48},{250,48}}, color={0,127,255}));
    connect(pipe25.port_a, pipe24.port_a)
      annotation (Line(points={{220,34},{220,52},{250,52}}, color={0,127,255}));
    connect(realExpression12.y, F9_2_load.u)
      annotation (Line(points={{331,68},{326,68}}, color={0,0,127}));
    connect(F9_2_load.y[1], F9_2.Q)
      annotation (Line(points={{303,68},{298,68},{298,58}}, color={0,0,127}));
    connect(pipe24.port_b, F9_2.port_a)
      annotation (Line(points={{270,52},{288,52}}, color={0,127,255}));
    connect(pipe24.port_a1, valveIncompressible12.port_b) annotation (Line(points
          ={{270,48},{280,48},{280,26},{290,26}}, color={0,127,255}));
    connect(F9_2.port_b, valveIncompressible12.port_a) annotation (Line(points={{308,
            52},{320,52},{320,26},{310,26}}, color={0,127,255}));
    connect(const12.y, valveIncompressible12.opening)
      annotation (Line(points={{296.7,9},{300,9},{300,18}}, color={0,0,127}));
    connect(realExpression16.y, F9_1_load.u)
      annotation (Line(points={{163,24},{170,24}}, color={0,0,127}));
    connect(F9_1_load.y[1], F9_1.Q)
      annotation (Line(points={{193,24},{196,24},{196,10}}, color={0,0,127}));
    connect(const13.y, valveIncompressible13.opening) annotation (Line(points={{194.7,
            -39},{194.7,-38},{198,-38},{198,-30}}, color={0,0,127}));
    connect(F9_1.port_a, pipe25.port_b)
      annotation (Line(points={{206,4},{220,4},{220,14}}, color={0,127,255}));
    connect(valveIncompressible13.port_b, pipe25.port_a1) annotation (Line(points
          ={{208,-22},{224,-22},{224,14}}, color={0,127,255}));
    connect(F9_1.port_b, valveIncompressible13.port_a) annotation (Line(points={{186,
            4},{176,4},{176,-22},{188,-22}}, color={0,127,255}));
    connect(pipe2.port_b, pipe30.port_a) annotation (Line(points={{-170,-52},{-138,
            -52},{-138,-78}}, color={0,127,255}));
    connect(pipe2.port_a1, pipe30.port_b1) annotation (Line(points={{-170,-56},{-134,
            -56},{-134,-78}}, color={0,127,255}));
    connect(realExpression20.y, F10_load.u)
      annotation (Line(points={{-25,-92},{-30,-92}}, color={0,0,127}));
    connect(F10.port_b, valveIncompressible17.port_a) annotation (Line(points={{-48,
            -108},{-42,-108},{-42,-138},{-46,-138}}, color={0,127,255}));
    connect(F10_load.y[1], F10.Q) annotation (Line(points={{-53,-92},{-58,-92},{-58,
            -102}}, color={0,0,127}));
    connect(const17.y, valveIncompressible17.opening) annotation (Line(points={{-61.3,
            -157},{-61.3,-152},{-56,-152},{-56,-146}}, color={0,0,127}));
    connect(pipe31.port_b, F10.port_a)
      annotation (Line(points={{-88,-108},{-68,-108}}, color={0,127,255}));
    connect(pipe31.port_a1, valveIncompressible17.port_b) annotation (Line(points={{-88,
            -112},{-82,-112},{-82,-138},{-66,-138}},      color={0,127,255}));
    connect(pipe30.port_b, pipe31.port_a) annotation (Line(points={{-138,-98},{-138,
            -108},{-108,-108}}, color={0,127,255}));
    connect(pipe30.port_a1, pipe31.port_b1) annotation (Line(points={{-134,-98},{-134,
            -112},{-108,-112}}, color={0,127,255}));
    connect(pipe30.port_b, pipe32.port_a)
      annotation (Line(points={{-138,-98},{-138,-140}}, color={0,127,255}));
    connect(pipe30.port_a1, pipe32.port_b1)
      annotation (Line(points={{-134,-98},{-134,-140}}, color={0,127,255}));
    connect(pipe32.port_a1, pipe33.port_b1) annotation (Line(points={{-134,-160},{
            -134,-186},{-54,-186}}, color={0,127,255}));
    connect(pipe32.port_b, pipe33.port_a) annotation (Line(points={{-138,-160},{-138,
            -182},{-54,-182}}, color={0,127,255}));
    connect(realExpression21.y, F13_load.u)
      annotation (Line(points={{197,-166},{186,-166}}, color={0,0,127}));
    connect(F13_load.y[1], F13.Q) annotation (Line(points={{163,-166},{158,-166},{
            158,-176}}, color={0,0,127}));
    connect(const18.y, valveIncompressible18.opening) annotation (Line(points={{154.7,
            -231},{154.7,-226},{160,-226},{160,-220}}, color={0,0,127}));
    connect(pipe33.port_b, F13.port_a)
      annotation (Line(points={{-34,-182},{148,-182}}, color={0,127,255}));
    connect(valveIncompressible18.port_b, pipe33.port_a1) annotation (Line(points
          ={{150,-212},{136,-212},{136,-186},{-34,-186}}, color={0,127,255}));
    connect(F13.port_b, valveIncompressible18.port_a) annotation (Line(points={{168,
            -182},{180,-182},{180,-212},{170,-212}}, color={0,127,255}));
    connect(pipe32.port_b, pipe34.port_a)
      annotation (Line(points={{-138,-160},{-138,-202}}, color={0,127,255}));
    connect(pipe32.port_a1, pipe34.port_b1)
      annotation (Line(points={{-134,-160},{-134,-202}}, color={0,127,255}));
    connect(pipe34.port_b, pipe35.port_a) annotation (Line(points={{-138,-222},{-138,
            -230},{-104,-230}}, color={0,127,255}));
    connect(pipe34.port_a1, pipe35.port_b1) annotation (Line(points={{-134,-222},{
            -134,-234},{-104,-234}}, color={0,127,255}));
    connect(realExpression22.y, F12_load.u)
      annotation (Line(points={{-15,-214},{-22,-214}}, color={0,0,127}));
    connect(const19.y, valveIncompressible19.opening) annotation (Line(points={{-55.3,
            -281},{-55.3,-280},{-50,-280},{-50,-270}}, color={0,0,127}));
    connect(F12.port_b, valveIncompressible19.port_a) annotation (Line(points={{-38,
            -230},{-32,-230},{-32,-262},{-40,-262}}, color={0,127,255}));
    connect(pipe35.port_b, F12.port_a)
      annotation (Line(points={{-84,-230},{-58,-230}}, color={0,127,255}));
    connect(F12_load.y[1], F12.Q) annotation (Line(points={{-45,-214},{-48,-214},
            {-48,-224}},color={0,0,127}));
    connect(valveIncompressible19.port_b, pipe35.port_a1) annotation (Line(points
          ={{-60,-262},{-66,-262},{-66,-234},{-84,-234}}, color={0,127,255}));
    connect(pipe34.port_b, pipe36.port_a)
      annotation (Line(points={{-138,-222},{-138,-276}}, color={0,127,255}));
    connect(pipe34.port_a1, pipe36.port_b1)
      annotation (Line(points={{-134,-222},{-134,-276}}, color={0,127,255}));
    connect(pipe37.port_a, pipe36.port_a) annotation (Line(points={{-174,-238},{-138,
            -238},{-138,-276}}, color={0,127,255}));
    connect(pipe37.port_b1, pipe35.port_b1)
      annotation (Line(points={{-174,-234},{-104,-234}}, color={0,127,255}));
    connect(F11.port_a, pipe37.port_b) annotation (Line(points={{-218,-258},{-208,
            -258},{-208,-238},{-194,-238}}, color={0,127,255}));
    connect(valveIncompressible20.port_b, pipe37.port_a1)
      annotation (Line(points={{-220,-234},{-194,-234}}, color={0,127,255}));
    connect(valveIncompressible20.port_a, F11.port_b) annotation (Line(points={{-240,
            -234},{-252,-234},{-252,-258},{-238,-258}}, color={0,127,255}));
    connect(const20.y, valveIncompressible20.opening) annotation (Line(points={{-239.3,
            -215},{-230,-215},{-230,-226}}, color={0,0,127}));
    connect(realExpression23.y, F11_load.u)
      annotation (Line(points={{-261,-280},{-256,-280}}, color={0,0,127}));
    connect(F11_load.y[1], F11.Q) annotation (Line(points={{-233,-280},{-228,
            -280},{-228,-264}},
                          color={0,0,127}));
    connect(F18.port_a, pipe38.port_b) annotation (Line(points={{-234,-346},{
            -200,-346},{-200,-324},{-190,-324}},
                                            color={0,127,255}));
    connect(valveIncompressible21.port_b, pipe38.port_a1)
      annotation (Line(points={{-232,-320},{-190,-320}}, color={0,127,255}));
    connect(const21.y, valveIncompressible21.opening) annotation (Line(points={{-257.3,
            -303},{-246,-303},{-246,-312},{-242,-312}},   color={0,0,127}));
    connect(realExpression24.y, F18_load.u)
      annotation (Line(points={{-271,-390},{-282,-390},{-282,-370},{-276,-370}},
                                                         color={0,0,127}));
    connect(F18_load.y[1], F18.Q) annotation (Line(points={{-253,-370},{-244,
            -370},{-244,-352}},
                          color={0,0,127}));
    connect(pipe38.port_b1, pipe36.port_a1) annotation (Line(points={{-170,-320},
            {-134,-320},{-134,-296}},color={0,127,255}));
    connect(pipe36.port_b, pipe38.port_a) annotation (Line(points={{-138,-296},
            {-138,-324},{-170,-324}},
                                color={0,127,255}));
    connect(pipe36.port_b, pipe39.port_a)
      annotation (Line(points={{-138,-296},{-138,-338}}, color={0,127,255}));
    connect(pipe36.port_a1, pipe39.port_b1)
      annotation (Line(points={{-134,-296},{-134,-338}}, color={0,127,255}));
    connect(realExpression25.y, F12_2_load.u)
      annotation (Line(points={{99,-278},{94,-278}}, color={0,0,127}));
    connect(const22.y, valveIncompressible22.opening) annotation (Line(points={{101.3,
            -345},{90,-345},{90,-334}},             color={0,0,127}));
    connect(pipe40.port_b, F12_2.port_a) annotation (Line(points={{32,-372},{40,-372},
            {40,-294},{56,-294}}, color={0,127,255}));
    connect(valveIncompressible22.port_b, pipe40.port_a1) annotation (Line(points={{80,-326},
            {44,-326},{44,-376},{32,-376}},           color={0,127,255}));
    connect(pipe39.port_a1, pipe40.port_b1) annotation (Line(points={{-134,-358},{
            -134,-376},{12,-376}}, color={0,127,255}));
    connect(pipe39.port_b, pipe40.port_a) annotation (Line(points={{-138,-358},{-138,
            -372},{12,-372}}, color={0,127,255}));
    connect(pipe40.port_b, pipe41.port_a)
      annotation (Line(points={{32,-372},{144,-372}}, color={0,127,255}));
    connect(pipe40.port_a1, pipe41.port_b1)
      annotation (Line(points={{32,-376},{144,-376}}, color={0,127,255}));
    connect(F14oad.y[1], F14.Q) annotation (Line(points={{191,-328},{198,-328},
            {198,-312}},
                    color={0,0,127}));
    connect(F14.port_a, pipe42.port_b) annotation (Line(points={{208,-306},{208,
            -308},{230,-308},{230,-340}},
                         color={0,127,255}));
    connect(valveIncompressible23.port_b, pipe42.port_a1) annotation (Line(points={{210,
            -282},{234,-282},{234,-340}},      color={0,127,255}));
    connect(F14oad.u, realExpression26.y)
      annotation (Line(points={{168,-328},{159,-328}}, color={0,0,127}));
    connect(pipe41.port_a1, pipe42.port_b1) annotation (Line(points={{164,-376},{234,
            -376},{234,-360}}, color={0,127,255}));
    connect(pipe41.port_b, pipe42.port_a) annotation (Line(points={{164,-372},{230,
            -372},{230,-360}}, color={0,127,255}));
    connect(realExpression27.y, F15_load.u)
      annotation (Line(points={{149,-412},{158,-412}}, color={0,0,127}));
    connect(const24.y, valveIncompressible24.opening) annotation (Line(points={{176.7,
            -475},{192,-475},{192,-466}},              color={0,0,127}));
    connect(F15.port_a, pipe43.port_b) annotation (Line(points={{196,-432},{230,
            -432},{230,-422}},
                         color={0,127,255}));
    connect(valveIncompressible24.port_b, pipe43.port_a1) annotation (Line(points={{202,
            -458},{234,-458},{234,-422}},      color={0,127,255}));
    connect(pipe41.port_b, pipe43.port_a) annotation (Line(points={{164,-372},{230,
            -372},{230,-402}}, color={0,127,255}));
    connect(pipe41.port_a1, pipe43.port_b1) annotation (Line(points={{164,-376},{234,
            -376},{234,-402}}, color={0,127,255}));
    connect(pipe39.port_b, pipe44.port_a)
      annotation (Line(points={{-138,-358},{-138,-424}}, color={0,127,255}));
    connect(pipe39.port_a1, pipe44.port_b1)
      annotation (Line(points={{-134,-358},{-134,-424}}, color={0,127,255}));
    connect(realExpression28.y, F16_load.u)
      annotation (Line(points={{9,-448},{4,-448}},     color={0,0,127}));
    connect(const25.y, valveIncompressible25.opening) annotation (Line(points={{-12.7,
            -517},{-18,-517},{-18,-518},{-30,-518},{-30,-506}},
                                                       color={0,0,127}));
    connect(pipe45.port_b, F16.port_a)
      annotation (Line(points={{-86,-466},{-42,-466}}, color={0,127,255}));
    connect(F16_load.y[1], F16.Q) annotation (Line(points={{-19,-448},{-32,-448},
            {-32,-460}},color={0,0,127}));
    connect(valveIncompressible25.port_b, pipe45.port_a1) annotation (Line(points={{-40,
            -498},{-76,-498},{-76,-470},{-86,-470}},      color={0,127,255}));
    connect(pipe44.port_a1, pipe45.port_b1) annotation (Line(points={{-134,-444},{
            -134,-470},{-106,-470}}, color={0,127,255}));
    connect(pipe44.port_b, pipe45.port_a) annotation (Line(points={{-138,-444},{-138,
            -466},{-106,-466}}, color={0,127,255}));
    connect(F17.port_a, pipe46.port_b) annotation (Line(points={{-232,-496},{
            -218,-496},{-218,-474},{-204,-474}},
                                            color={0,127,255}));
    connect(valveIncompressible26.port_b, pipe46.port_a1)
      annotation (Line(points={{-234,-470},{-204,-470}}, color={0,127,255}));
    connect(const26.y, valveIncompressible26.opening) annotation (Line(points={{-249.3,
            -453},{-249.3,-454},{-244,-454},{-244,-462}}, color={0,0,127}));
    connect(realExpression29.y, F17_load.u)
      annotation (Line(points={{-265,-546},{-276,-546},{-276,-522},{-268,-522}},
                                                         color={0,0,127}));
    connect(F17_load.y[1], F17.Q) annotation (Line(points={{-245,-522},{-242,
            -522},{-242,-502}},
                          color={0,0,127}));
    connect(pipe46.port_b1, pipe45.port_b1)
      annotation (Line(points={{-184,-470},{-106,-470}}, color={0,127,255}));
    connect(pipe46.port_a, pipe45.port_a) annotation (Line(points={{-184,-474},{-138,
            -474},{-138,-466},{-106,-466}}, color={0,127,255}));
    connect(valveIncompressible26.port_a, F17.port_b) annotation (Line(points={{-254,
            -470},{-260,-470},{-260,-496},{-252,-496}}, color={0,127,255}));
    connect(pipe.port_a1, pipe47.port_b1) annotation (Line(points={{-228,-36},{-216,
            -36},{-216,-140},{-250,-140}}, color={0,127,255}));
    connect(pipe.port_b, pipe47.port_a) annotation (Line(points={{-228,-32},{-220,
            -32},{-220,-136},{-250,-136}}, color={0,127,255}));
    connect(const27.y, valveIncompressible27.opening) annotation (Line(points={{-377.3,
            -377},{-360,-377},{-360,-366}}, color={0,0,127}));
    connect(F19_load.y[1], F19.Q) annotation (Line(points={{-383,-304},{-364,
            -304},{-364,-314}},
                          color={0,0,127}));
    connect(pipe47.port_b, F19.port_a) annotation (Line(points={{-270,-136},{
            -312,-136},{-312,-320},{-354,-320}},
                                            color={0,127,255}));
    connect(valveIncompressible27.port_b, pipe47.port_a1) annotation (Line(points={{-350,
            -358},{-308,-358},{-308,-140},{-270,-140}},       color={0,127,255}));
    connect(realExpression3.y, F19_load.u)
      annotation (Line(points={{-427,-304},{-406,-304}}, color={0,0,127}));
    connect(temperature8.port, pipe11.port_b) annotation (Line(points={{-154,
            210},{-154,204},{-144,204}},       color={0,127,255}));
    connect(pressure7.port, pipe11.port_b) annotation (Line(points={{-158,202},
            {-158,206},{-154,206},{-154,204},{-144,204}},
                                                    color={0,127,255}));
    connect(pressure13.port, pipe19.port_b) annotation (Line(points={{328,204},
            {328,206},{340,206}},
                             color={0,127,255}));
    connect(temperature14.port, pipe19.port_b) annotation (Line(points={{332,212},
            {332,206},{340,206}}, color={0,127,255}));
    connect(temperature12.port, pipe15.port_b) annotation (Line(points={{104,214},
            {104,212},{112,212},{112,208}},
                                        color={0,127,255}));
    connect(pressure11.port, pipe15.port_b) annotation (Line(points={{100,206},
            {100,212},{112,212},{112,208}},
                                     color={0,127,255}));
    connect(temperature11.port, pipe14.port_b) annotation (Line(points={{24,214},
            {24,212},{34,212},{34,208}},
                                     color={0,127,255}));
    connect(pressure10.port, temperature11.port) annotation (Line(points={{20,206},
            {20,212},{24,212},{24,214}},
                                      color={0,127,255}));
    connect(temperature10.port, pipe12.port_b) annotation (Line(points={{-70,212},
            {-70,210},{-62,210},{-62,204}}, color={0,127,255}));
    connect(pressure9.port, pipe12.port_b) annotation (Line(points={{-74,204},{
            -74,210},{-62,210},{-62,204}},
                                       color={0,127,255}));
    connect(valveIncompressible3.port_b, volumeFlowRate3.port_a) annotation (Line(
          points={{-156,268},{-130,268},{-130,264}}, color={0,127,255}));
    connect(volumeFlowRate3.port_b, pipe11.port_a1) annotation (Line(points={{-130,
            244},{-130,224},{-140,224},{-140,204}}, color={0,127,255}));
    connect(valveIncompressible5.port_b, volumeFlowRate4.port_a) annotation (Line(
          points={{-68,276},{-46,276},{-46,266}}, color={0,127,255}));
    connect(volumeFlowRate4.port_b, pipe12.port_a1) annotation (Line(points={{-46,246},
            {-46,226},{-58,226},{-58,204}},      color={0,127,255}));
    connect(valveIncompressible6.port_b, volumeFlowRate5.port_a)
      annotation (Line(points={{22,272},{46,272},{46,268}},color={0,127,255}));
    connect(volumeFlowRate5.port_b, pipe14.port_a1)
      annotation (Line(points={{46,248},{46,228},{38,228},{38,208}},
                                                   color={0,127,255}));
    connect(valveIncompressible7.port_b, volumeFlowRate6.port_a) annotation (
        Line(points={{106,280},{128,280},{128,274}},
                                                  color={0,127,255}));
    connect(volumeFlowRate6.port_b, pipe15.port_a1) annotation (Line(points={{128,254},
            {128,246},{116,246},{116,208}},      color={0,127,255}));
    connect(valveIncompressible9.port_b, volumeFlowRate8.port_a) annotation (
        Line(points={{334,278},{356,278},{356,274}}, color={0,127,255}));
    connect(volumeFlowRate8.port_b, pipe19.port_a1) annotation (Line(points={{356,254},
            {354,254},{354,206},{344,206}},          color={0,127,255}));
    connect(pressure14.port, volumeFlowRate3.port_a) annotation (Line(points={{-132,
            274},{-132,264},{-130,264}},                 color={0,127,255}));
    connect(temperature15.port, volumeFlowRate3.port_a) annotation (Line(points={{-150,
            272},{-150,268},{-130,268},{-130,264}},       color={0,127,255}));
    connect(temperature20.port, volumeFlowRate8.port_a) annotation (Line(points={{338,288},
            {338,278},{356,278},{356,274}},           color={0,127,255}));
    connect(pressure19.port, volumeFlowRate8.port_a)
      annotation (Line(points={{356,290},{356,274}}, color={0,127,255}));
    connect(temperature18.port, volumeFlowRate6.port_a) annotation (Line(points={{110,286},
            {110,280},{128,280},{128,274}},       color={0,127,255}));
    connect(pressure17.port, volumeFlowRate6.port_a)
      annotation (Line(points={{128,288},{128,274}},
                                                   color={0,127,255}));
    connect(temperature17.port, volumeFlowRate5.port_a) annotation (Line(points={{24,278},
            {24,272},{46,272},{46,268}},        color={0,127,255}));
    connect(pressure16.port, volumeFlowRate5.port_a) annotation (Line(points={{42,280},
            {42,272},{46,272},{46,268}},         color={0,127,255}));
    connect(pressure15.port, volumeFlowRate4.port_a)
      annotation (Line(points={{-46,284},{-46,266}}, color={0,127,255}));
    connect(temperature16.port, volumeFlowRate4.port_a) annotation (Line(points={{-64,282},
            {-64,276},{-46,276},{-46,266}},           color={0,127,255}));
    connect(temperature9.port, valveIncompressible2.port_b) annotation (Line(
          points={{-116,64},{-116,66},{-74,66}},           color={0,127,255}));
    connect(pressure8.port, valveIncompressible2.port_b) annotation (Line(
          points={{-92,62},{-92,66},{-74,66}}, color={0,127,255}));
    connect(F6.port_b, volumeFlowRate9.port_a) annotation (Line(points={{-42,96},
            {-42,90},{-26,90}}, color={0,127,255}));
    connect(volumeFlowRate9.port_b, valveIncompressible2.port_a) annotation (
        Line(points={{-26,70},{-24,70},{-24,66},{-54,66}}, color={0,127,255}));
    connect(F7.port_b, volumeFlowRate10.port_a) annotation (Line(points={{240,
            124},{264,124},{264,118}}, color={0,127,255}));
    connect(volumeFlowRate10.port_b, valveIncompressible10.port_a) annotation (
        Line(points={{264,98},{264,94},{242,94}}, color={0,127,255}));
    connect(pressure20.port, pipe9.port_b) annotation (Line(points={{-68,106},{
            -68,96},{-96,96}}, color={0,127,255}));
    connect(temperature21.port, pipe9.port_b) annotation (Line(points={{-86,112},
            {-86,96},{-96,96}}, color={0,127,255}));
    connect(F8.port_b, volumeFlowRate11.port_a) annotation (Line(points={{-52,
            -2},{-20,-2},{-20,-8}}, color={0,127,255}));
    connect(volumeFlowRate11.port_b, valveIncompressible4.port_a) annotation (
        Line(points={{-20,-28},{-20,-36},{-50,-36}}, color={0,127,255}));
    connect(pressure21.port, valveIncompressible4.port_b) annotation (Line(
          points={{-82,-42},{-82,-36},{-70,-36}}, color={0,127,255}));
    connect(temperature22.port, valveIncompressible4.port_b) annotation (Line(
          points={{-104,-46},{-106,-46},{-106,-36},{-70,-36}}, color={0,127,255}));
    connect(temperature23.port, valveIncompressible1.port_b) annotation (Line(
          points={{-194,90},{-194,70},{-198,70}}, color={0,127,255}));
    connect(pressure22.port, valveIncompressible1.port_a) annotation (Line(
          points={{-244,88},{-244,70},{-218,70}}, color={0,127,255}));
    connect(temperature24.port, F5.port_a) annotation (Line(points={{-190,36},{
            -190,48},{-194,48}}, color={0,127,255}));
    connect(pressure23.port, pipe7.port_b) annotation (Line(points={{-168,34},{
            -168,40},{-184,40},{-184,48},{-180,48}}, color={0,127,255}));
    connect(pressure24.port, F8.port_a)
      annotation (Line(points={{-78,6},{-78,-2},{-72,-2}}, color={0,127,255}));
    connect(temperature25.port, F8.port_a) annotation (Line(points={{-98,6},{
            -98,4},{-88,4},{-88,-2},{-72,-2}}, color={0,127,255}));
    connect(pressure25.port, F10.port_a) annotation (Line(points={{-70,-102},{
            -70,-108},{-68,-108}}, color={0,127,255}));
    connect(temperature26.port, pipe31.port_b)
      annotation (Line(points={{-88,-102},{-88,-108}}, color={0,127,255}));
    connect(pressure26.port, valveIncompressible17.port_b) annotation (Line(
          points={{-92,-136},{-92,-132},{-82,-132},{-82,-138},{-66,-138}},
          color={0,127,255}));
    connect(temperature27.port, valveIncompressible17.port_b) annotation (Line(
          points={{-114,-140},{-114,-132},{-82,-132},{-82,-138},{-66,-138}},
          color={0,127,255}));
    connect(pressure27.port, pipe35.port_a1) annotation (Line(points={{-88,-264},
            {-88,-262},{-66,-262},{-66,-234},{-84,-234}}, color={0,127,255}));
    connect(temperature28.port, pipe35.port_a1) annotation (Line(points={{-110,
            -268},{-110,-262},{-66,-262},{-66,-234},{-84,-234}}, color={0,127,
            255}));
    connect(pressure28.port, pipe33.port_a1) annotation (Line(points={{120,-216},
            {120,-212},{136,-212},{136,-186},{-34,-186}}, color={0,127,255}));
    connect(temperature29.port, pipe33.port_a1) annotation (Line(points={{98,
            -220},{98,-212},{136,-212},{136,-186},{-34,-186}}, color={0,127,255}));
    connect(pressure29.port, F12_2.port_a) annotation (Line(points={{28,-302},{
            28,-294},{56,-294}}, color={0,127,255}));
    connect(temperature30.port, F12_2.port_a) annotation (Line(points={{6,-306},
            {6,-294},{56,-294}}, color={0,127,255}));
    connect(F12_2.port_b, valveIncompressible22.port_a) annotation (Line(points
          ={{76,-294},{108,-294},{108,-326},{100,-326}}, color={0,127,255}));
    connect(temperature31.port, pipe40.port_a1) annotation (Line(points={{52,
            -338},{52,-326},{44,-326},{44,-376},{32,-376}}, color={0,127,255}));
    connect(pressure30.port, pipe40.port_a1) annotation (Line(points={{74,-334},
            {74,-326},{44,-326},{44,-376},{32,-376}}, color={0,127,255}));
    connect(valveIncompressible23.port_a, F14.port_b) annotation (Line(points={
            {190,-282},{172,-282},{172,-306},{188,-306}}, color={0,127,255}));
    connect(pressure31.port, pipe42.port_b) annotation (Line(points={{220,-332},
            {220,-328},{230,-328},{230,-340}}, color={0,127,255}));
    connect(temperature32.port, pipe42.port_b) annotation (Line(points={{202,
            -340},{202,-328},{230,-328},{230,-340}}, color={0,127,255}));
    connect(temperature33.port, pipe42.port_a1) annotation (Line(points={{250,
            -288},{250,-282},{234,-282},{234,-340}}, color={0,127,255}));
    connect(pressure32.port, pipe42.port_a1) annotation (Line(points={{272,-284},
            {272,-282},{234,-282},{234,-340}}, color={0,127,255}));
    connect(const23.y, valveIncompressible23.opening) annotation (Line(points={
            {180.7,-267},{200,-267},{200,-274}}, color={0,0,127}));
    connect(F12_2_load.y[1], F12_2.Q) annotation (Line(points={{71,-278},{66,
            -278},{66,-288}}, color={0,0,127}));
    connect(F15_load.y[1], F15.Q) annotation (Line(points={{181,-412},{186,-412},
            {186,-426}}, color={0,0,127}));
    connect(F15.port_b, valveIncompressible24.port_a) annotation (Line(points={
            {176,-432},{164,-432},{164,-458},{182,-458}}, color={0,127,255}));
    connect(temperature34.port, pipe43.port_a1) annotation (Line(points={{216,
            -474},{216,-458},{234,-458},{234,-422}}, color={0,127,255}));
    connect(pressure33.port, pipe43.port_a1)
      annotation (Line(points={{234,-466},{234,-422}}, color={0,127,255}));
    connect(pressure34.port, pipe43.port_b) annotation (Line(points={{218,-410},
            {218,-432},{230,-432},{230,-422}}, color={0,127,255}));
    connect(temperature35.port, pipe43.port_b) annotation (Line(points={{196,
            -414},{196,-424},{204,-424},{204,-432},{230,-432},{230,-422}},
          color={0,127,255}));
    connect(F16.port_b, valveIncompressible25.port_a) annotation (Line(points={
            {-22,-466},{-12,-466},{-12,-498},{-20,-498}}, color={0,127,255}));
    connect(temperature36.port, F16.port_a) annotation (Line(points={{-78,-454},
            {-78,-466},{-42,-466}}, color={0,127,255}));
    connect(pressure35.port, F16.port_a) annotation (Line(points={{-52,-456},{
            -52,-466},{-42,-466}}, color={0,127,255}));
    connect(pressure36.port, pipe45.port_a1) annotation (Line(points={{-50,-506},
            {-50,-498},{-76,-498},{-76,-470},{-86,-470}}, color={0,127,255}));
    connect(temperature37.port, pipe45.port_a1) annotation (Line(points={{-76,
            -510},{-76,-470},{-86,-470}}, color={0,127,255}));
    connect(pressure37.port, F12.port_a) annotation (Line(points={{-64,-218},{
            -64,-230},{-58,-230}}, color={0,127,255}));
    connect(temperature38.port, pipe35.port_b)
      annotation (Line(points={{-84,-216},{-84,-230}}, color={0,127,255}));
    connect(pressure38.port, F13.port_a) annotation (Line(points={{138,-174},{
            138,-182},{148,-182}}, color={0,127,255}));
    connect(temperature39.port, F13.port_a) annotation (Line(points={{118,-172},
            {118,-182},{148,-182}}, color={0,127,255}));
    connect(F19.port_b, valveIncompressible27.port_a) annotation (Line(points={
            {-374,-320},{-386,-320},{-386,-358},{-370,-358}}, color={0,127,255}));
    connect(valveIncompressible21.port_a, F18.port_b) annotation (Line(points={
            {-252,-320},{-266,-320},{-266,-346},{-254,-346}}, color={0,127,255}));
    connect(temperature40.port, pipe46.port_b) annotation (Line(points={{-218,
            -506},{-218,-474},{-204,-474}}, color={0,127,255}));
    connect(pressure39.port, pipe46.port_b) annotation (Line(points={{-192,-502},
            {-192,-496},{-218,-496},{-218,-474},{-204,-474}}, color={0,127,255}));
    connect(temperature41.port, valveIncompressible26.port_b) annotation (Line(
          points={{-232,-452},{-232,-470},{-234,-470}}, color={0,127,255}));
    connect(pressure40.port, pipe46.port_a1) annotation (Line(points={{-208,
            -454},{-208,-470},{-204,-470}}, color={0,127,255}));
    connect(temperature42.port, valveIncompressible20.port_b) annotation (Line(
          points={{-216,-218},{-216,-234},{-220,-234}}, color={0,127,255}));
    connect(pressure41.port, pipe37.port_a1) annotation (Line(points={{-196,
            -230},{-196,-234},{-194,-234}}, color={0,127,255}));
    connect(temperature43.port, pipe37.port_b) annotation (Line(points={{-208,
            -264},{-208,-238},{-194,-238}}, color={0,127,255}));
    connect(pressure42.port, pipe37.port_b) annotation (Line(points={{-186,-260},
            {-186,-258},{-208,-258},{-208,-238},{-194,-238}}, color={0,127,255}));
    connect(temperature44.port, pipe38.port_a1) annotation (Line(points={{-224,
            -316},{-224,-320},{-190,-320}}, color={0,127,255}));
    connect(pressure43.port, pipe38.port_a1) annotation (Line(points={{-202,
            -318},{-202,-320},{-190,-320}}, color={0,127,255}));
    connect(temperature45.port, pipe38.port_b) annotation (Line(points={{-222,
            -356},{-222,-346},{-200,-346},{-200,-324},{-190,-324}}, color={0,
            127,255}));
    connect(pressure44.port, pipe38.port_b) annotation (Line(points={{-196,-352},
            {-196,-346},{-200,-346},{-200,-324},{-190,-324}}, color={0,127,255}));
    connect(temperature46.port, pipe47.port_a1) annotation (Line(points={{-336,
            -372},{-336,-358},{-308,-358},{-308,-140},{-270,-140}}, color={0,
            127,255}));
    connect(pressure45.port, pipe47.port_a1) annotation (Line(points={{-310,
            -368},{-310,-358},{-308,-358},{-308,-140},{-270,-140}}, color={0,
            127,255}));
    connect(temperature47.port, F19.port_a) annotation (Line(points={{-350,-310},
            {-350,-320},{-354,-320}}, color={0,127,255}));
    connect(pressure46.port, F19.port_a) annotation (Line(points={{-328,-314},{
            -328,-320},{-354,-320}}, color={0,127,255}));
    connect(F2_2oad.y[1], F2.Q) annotation (Line(points={{211,236},{216,236},{
            216,250}}, color={0,0,127}));
    connect(const11.y, valveIncompressible11.opening) annotation (Line(points={{200.7,
            297},{206,297},{206,288},{214,288}},        color={0,0,127}));
    connect(F2.port_a, pipe48.port_b) annotation (Line(points={{226,256},{230,
            256},{230,244},{246,244},{246,208},{230,208}}, color={0,127,255}));
    connect(F2_2oad.u, realExpression14.y) annotation (Line(points={{188,236},{
            188,214},{191,214}}, color={0,0,127}));
    connect(valveIncompressible11.port_a, F2.port_b) annotation (Line(points={{
            204,280},{204,268},{206,268},{206,256}}, color={0,127,255}));
    connect(pressure47.port,pipe48. port_b) annotation (Line(points={{218,206},
            {224,206},{224,208},{230,208}},
                             color={0,127,255}));
    connect(temperature48.port,pipe48. port_b) annotation (Line(points={{222,214},
            {222,208},{230,208}}, color={0,127,255}));
    connect(valveIncompressible11.port_b, volumeFlowRate12.port_a) annotation (
        Line(points={{224,280},{224,276},{246,276}}, color={0,127,255}));
    connect(volumeFlowRate12.port_b, pipe48.port_a1) annotation (Line(points={{246,256},
            {246,208},{234,208}},          color={0,127,255}));
    connect(temperature49.port, volumeFlowRate12.port_a) annotation (Line(
          points={{228,290},{228,276},{246,276}}, color={0,127,255}));
    connect(pressure48.port, volumeFlowRate12.port_a)
      annotation (Line(points={{246,292},{246,276}}, color={0,127,255}));
    connect(pipe48.port_b1, pipe16.port_a1) annotation (Line(points={{234,188},
            {234,174},{148,174}}, color={0,127,255}));
    connect(pipe48.port_a, pipe18.port_a) annotation (Line(points={{230,188},{
            230,178},{260,178}}, color={0,127,255}));
    connect(boundary.ports[2], pump1.port_a) annotation (Line(points={{-416,-33},
            {-404,-33},{-404,-62},{-390,-62}}, color={0,127,255}));
    connect(pump1.port_b, pressure.port) annotation (Line(points={{-370,-62},{
            -348,-62},{-348,-32},{-258,-32},{-258,-28}}, color={0,127,255}));
    connect(temperature1.port, pump.port_a) annotation (Line(points={{-404,-22},
            {-404,-32},{-390,-32}}, color={0,127,255}));
    annotation (
      Icon(coordinateSystem(preserveAspectRatio=false, extent={{-500,-540},{380,320}}),
                      graphics={
          Ellipse(lineColor = {75,138,73},
                  fillColor={255,255,255},
                  fillPattern = FillPattern.Solid,
                  extent={{-100,-100},{100,100}}),
          Polygon(lineColor = {0,0,255},
                  fillColor = {75,138,73},
                  pattern = LinePattern.None,
                  fillPattern = FillPattern.Solid,
                  points={{-36,60},{64,0},{-36,-60},{-36,60}})}),
      Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-500,-540},{380,
              320}}), graphics={Rectangle(
            extent={{-516,36},{-300,-114}},
            lineColor={238,46,47},
            lineThickness=0.5,
            pattern=LinePattern.Dash), Text(
            extent={{-452,78},{-392,48}},
            textColor={238,46,47},
            textString="热源")}),
      experiment(StopTime=1854000, __Dymola_Algorithm="Dassl"));
  end HeatingNetWork_Case02;

  model test
    Modelica.Fluid.Sources.Boundary_pT boundary(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      use_p_in=false,
      use_T_in=true,
      p=300000,
      T=323.15,
      nPorts=1) "供水边界"
      annotation (Placement(transformation(extent={{-74,12},{-54,-8}})));
    Pipe pipe(
      Length=20,
      Diameter(displayUnit="mm") = 0.15,
      roughness(displayUnit="mm"))
      annotation (Placement(transformation(extent={{20,-10},{40,10}})));
    Modelica.Fluid.Machines.ControlledPump pump(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      p_b_start=600000,
      N_nominal(displayUnit="rpm"),
      p_a_nominal=300000,
      p_b_nominal=600000,
      m_flow_nominal=75/3600*1000,
      use_m_flow_set=false)
                           "循环泵"
      annotation (Placement(transformation(extent={{-34,-6},{-14,14}})));
    Modelica.Fluid.Sources.Boundary_pT boundary1(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      use_p_in=false,
      use_T_in=false,
      p=200000,
      T=323.15,
      nPorts=1) "回水边界"
      annotation (Placement(transformation(extent={{-72,-44},{-52,-64}})));
    Modelica.Blocks.Sources.RealExpression realExpression13(y=time/3600)
      annotation (Placement(transformation(extent={{-140,-12},{-120,8}})));
    Modelica.Blocks.Tables.CombiTable1Ds Tg(table=[0,318.88; 2,319.04; 4,319.19;
          6,319.4; 8,319.41; 10,319.66; 12,319.95; 14,319.17; 16,318.68; 18,
          317.77; 20,316.86; 22,316.26; 24,318.27; 26,319.2; 28,319.09; 30,
          319.22; 32,318.24; 34,318.3; 36,318.07; 38,317.98; 40,317.53; 42,
          316.78; 44,316.75; 46,317.14; 48,317.17; 50,317.13; 52,317.16; 54,
          317.17; 56,317.18; 58,317.82; 60,318.12; 62,318.15; 64,317.99; 66,
          317.82; 68,318.19; 70,318.16; 72,318.07; 74,318.34; 76,318.16; 78,
          318.19; 80,318.11; 82,317.74; 84,317.03; 86,317.32; 88,317.3; 90,
          317.08; 92,317.04; 94,317.18; 96,317.01; 98,317.13; 100,317.18; 102,
          317.19; 104,318.79; 106,319.01; 108,318.96; 110,318.09; 112,317.38;
          114,317.05; 116,317.23; 118,317.18; 120,317.1; 122,317.14; 124,317.24;
          126,317.05; 128,316.62; 130,315.15; 132,315.05; 134,314.22; 136,
          314.34; 138,314.59; 140,314.24; 142,314.19; 144,314.01; 146,314.25;
          148,314.26; 150,314.24; 152,314.25; 154,313.59; 156,312.39; 158,
          311.03; 160,310.47; 162,312.2; 164,311.67; 166,311.11; 168,311.17;
          170,311.19; 172,311.12; 174,311.03; 176,311.47; 178,312.58; 180,
          311.33; 182,310.19; 184,310.36; 186,310.35; 188,310.67; 190,310.48;
          192,310.82; 194,310.55; 196,310.57; 198,310.61; 200,310.65; 202,
          311.65; 204,312.24; 206,312.43; 208,313.35; 210,314.13; 212,314.62;
          214,315.38; 216,315.59; 218,315.64; 220,315.47; 222,315.8; 224,316.81;
          226,317.43; 228,317.84; 230,317.62; 232,318.26; 234,318.9; 236,318.77;
          238,319.23; 240,319.16; 242,319.19; 244,319.27; 246,319.07; 248,318.4;
          250,318.7; 252,318.71; 254,318.52; 256,318.44; 258,318.96; 260,318.5;
          262,318.58; 264,318.31; 266,318.81; 268,318.45; 270,318.84; 272,
          318.21; 274,318.21; 276,318.16; 278,317.64; 280,317.74; 282,317.2;
          284,317; 286,317.09; 288,317.27; 290,317.21; 292,317.11; 294,317.11;
          296,317.11; 298,317.24; 300,316.7; 302,316.71; 304,316.67; 306,316.62;
          308,316.72; 310,316.78; 312,316.63; 314,316.61; 316,316.67; 318,
          316.76; 320,316.78; 322,316.53; 324,316.58; 326,316.77; 328,316.41;
          330,316.11; 332,316.05; 334,316.1; 336,316.15; 338,316.09; 340,316.05;
          342,316.11; 344,316.32; 346,316.08; 348,316.22; 350,316.11; 352,
          317.11; 354,317.33; 356,317.74; 358,317.49; 360,317.64; 362,317.65;
          364,317.6; 366,317.7; 368,317.65; 370,317.67; 372,317.86; 374,318.7;
          376,319.29; 378,320.54; 380,320.59; 382,320.66; 384,320.58; 386,
          320.69; 388,320.55; 390,320.7; 392,320.7; 394,320.94; 396,321.14; 398,
          321.17; 400,321.09; 402,321.15; 404,321.16; 406,321.12; 408,321.07;
          410,321.12; 412,321.24; 414,321.09; 416,321.41; 418,322.16; 420,
          322.22; 422,322.16; 424,321.59; 426,321.6; 428,321.74; 430,321.64;
          432,321.73; 434,321.54; 436,321.61; 438,321.59; 440,321.65; 442,
          321.66; 444,321.82; 446,322.18; 448,322.1; 450,322.12; 452,322.62;
          454,322.57; 456,322.62; 458,322.72; 460,322.59; 462,322.61; 464,
          322.63; 466,322.13; 468,321.51; 470,321.03; 472,321.26; 474,321.19;
          476,321.16; 478,321.15; 480,321.22; 482,321.13; 484,321.14; 486,
          321.17; 488,321.09; 490,321.14; 492,320.65; 494,320.67; 496,320.66;
          498,320.52; 500,320.23; 502,320.11; 504,320.09; 506,320.15; 508,320.2;
          510,320.25; 512,320.1; 514,320.25; 516,320.12; 518,320.15; 520,320.19;
          522,320.11; 524,320.24; 526,320.22; 528,320.12; 530,320.16; 532,
          320.23; 534,320.21; 536,320.11; 538,319.93; 540,320.26; 542,320.08;
          544,320.27; 546,320.02; 548,320.04; 550,320.07; 552,320.22; 554,
          320.08; 556,320.22; 558,320.06; 560,320.06; 562,319.97; 564,319.31;
          566,319.38; 568,319.14; 570,319.48; 572,319.2; 574,319.11])
                                                        "供水温度"
      annotation (Placement(transformation(extent={{-110,-12},{-90,8}})));
    Pipe pipe1(Length=10, Diameter(displayUnit="mm") = 0.1) annotation (
        Placement(transformation(
          extent={{-10,-10},{10,10}},
          rotation=90,
          origin={66,28})));
    Pipe pipe2(Length=10, Diameter(displayUnit="mm") = 0.1) annotation (
        Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=90,
          origin={66,-32})));
    User F1(
      Length=50,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=1) "1栋"
      annotation (Placement(transformation(extent={{76,60},{96,80}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible16(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.equalPercentage)
      annotation (Placement(transformation(
          extent={{10,10},{-10,-10}},
          rotation=0,
          origin={120,52})));
    Modelica.Blocks.Sources.Constant const(k=1)
      annotation (Placement(transformation(extent={{88,18},{108,38}})));
    Modelica.Blocks.Tables.CombiTable1Ds F1oad(table=[0,-41604.2088; 2,-42473.9832;
          4,-43005.512; 6,-43826.9656; 8,-43633.6824; 10,-43826.9656; 12,-44503.4568;
          14,-41024.3592; 16,-39478.0936; 18,-38270.0736; 20,-36240.6; 22,-36965.412;
          24,-41507.5672; 26,-44600.0984; 28,-41990.7752; 30,-42570.6248; 32,-39284.8104;
          34,-41604.2088; 36,-40299.5472; 38,-40009.6224; 40,-39139.848; 42,-36820.4496;
          44,-37158.6952; 46,-39236.4896; 48,-39478.0936; 50,-39429.7728; 52,-39623.056;
          54,-39671.3768; 56,-40009.6224; 58,-41507.5672; 60,-41121.0008; 62,-40831.076;
          64,-40154.5848; 66,-39429.7728; 68,-41362.6048; 70,-41217.6424; 72,-40831.076;
          74,-42135.7376; 76,-41265.9632; 78,-41362.6048; 80,-41024.3592; 82,-39526.4144;
          84,-37738.5448; 86,-39623.056; 88,-39478.0936; 90,-38270.0736; 92,-38125.1112;
          94,-38898.244; 96,-38318.3944; 98,-39236.4896; 100,-39574.7352; 102,-39768.0184;
          104,-44455.136; 106,-43053.8328; 108,-43343.7576; 110,-39719.6976;
          112,-38656.64; 114,-38511.6776; 116,-39478.0936; 118,-39284.8104; 120,
          -38849.9232; 122,-39091.5272; 124,-39526.4144; 126,-38656.64; 128,-37448.62;
          130,-34356.0888; 132,-34694.3344; 134,-31940.0488; 136,-33824.56; 138,
          -33921.2016; 140,-32809.8232; 142,-33244.7104; 144,-32423.2568; 146,-33486.3144;
          148,-33631.2768; 150,-33582.956; 152,-33582.956; 154,-30683.708; 156,
          -27736.1392; 158,-25223.4576; 160,-26673.0816; 162,-30973.6328; 164,-27542.856;
          166,-26624.7608; 168,-27687.8184; 170,-27977.7432; 172,-27687.8184;
          174,-27301.252; 176,-29330.7256; 178,-31021.9536; 180,-25223.4576;
          182,-24208.7208; 184,-26576.44; 186,-25368.42; 188,-26431.4776; 190,-25416.7408;
          192,-26963.0064; 194,-25561.7032; 196,-25706.6656; 198,-26383.1568;
          200,-27059.648; 202,-30490.4248; 204,-31070.2744; 206,-31070.2744;
          208,-33293.0312; 210,-34259.4472; 212,-35998.996; 214,-37158.6952;
          216,-36868.7704; 218,-36917.0912; 220,-36288.9208; 222,-38173.432;
          224,-41362.6048; 226,-41845.8128; 228,-41797.492; 230,-40444.5096;
          232,-42763.908; 234,-44068.5696; 236,-43247.116; 238,-44261.8528; 240,
          -43633.6824; 242,-43778.6448; 244,-44261.8528; 246,-43247.116; 248,-41314.284;
          250,-43730.324; 252,-42715.5872; 254,-41362.6048; 256,-41169.3216;
          258,-43971.928; 260,-41652.5296; 262,-42039.096; 264,-40782.7552; 266,
          -43247.116; 268,-41604.2088; 270,-43537.0408; 272,-41652.5296; 274,-42087.4168;
          276,-41362.6048; 278,-38994.8856; 280,-40782.7552; 282,-39284.8104;
          284,-38801.6024; 286,-39284.8104; 288,-40299.5472; 290,-40057.9432;
          292,-39671.3768; 294,-39768.0184; 296,-40009.6224; 298,-40396.1888;
          300,-38366.7152; 302,-38753.2816; 304,-38608.3192; 306,-38511.6776;
          308,-39043.2064; 310,-39381.452; 312,-38656.64; 314,-38704.9608; 316,
          -39139.848; 318,-39768.0184; 320,-40009.6224; 322,-38801.6024; 324,-38946.5648;
          326,-39574.7352; 328,-37738.5448; 330,-37400.2992; 332,-37448.62; 334,
          -37641.9032; 336,-37641.9032; 338,-37351.9784; 340,-37255.3368; 342,-37641.9032;
          344,-39139.848; 346,-37931.828; 348,-38318.3944; 350,-37496.9408; 352,
          -41410.9256; 354,-40879.3968; 356,-42039.096; 358,-40106.264; 360,-40831.076;
          362,-41072.68; 364,-41024.3592; 366,-41652.5296; 368,-41749.1712; 370,
          -42135.7376; 372,-42473.9832; 374,-44165.2112; 376,-46146.364; 378,-49093.9328;
          380,-47257.7424; 382,-47595.988; 384,-47257.7424; 386,-47885.9128;
          388,-47306.0632; 390,-48079.196; 392,-48272.4792; 394,-48997.2912;
          396,-48369.1208; 398,-48175.8376; 400,-47789.2712; 402,-48175.8376;
          404,-48224.1584; 406,-47934.2336; 408,-47934.2336; 410,-48272.4792;
          412,-49045.612; 414,-48465.7624; 416,-50108.6696; 418,-51220.048; 420,
          -50398.5944; 422,-49770.424; 424,-48079.196; 426,-49190.5744; 428,-50301.9528;
          430,-50108.6696; 432,-50736.84; 434,-50060.3488; 436,-50543.5568; 438,
          -50688.5192; 440,-51268.3688; 442,-51026.7648; 444,-51171.7272; 446,-51413.3312;
          448,-50978.444; 450,-51461.652; 452,-53249.5216; 454,-52283.1056; 456,
          -52573.0304; 458,-53201.2008; 460,-52476.3888; 462,-52814.6344; 464,-53007.9176;
          466,-50833.4816; 468,-49335.5368; 470,-48127.5168; 472,-49625.4616;
          474,-49625.4616; 476,-49480.4992; 478,-49432.1784; 480,-49770.424;
          482,-49432.1784; 484,-49577.1408; 486,-49770.424; 488,-49625.4616;
          490,-49528.82; 492,-47692.6296; 494,-47740.9504; 496,-47934.2336; 498,
          -47402.7048; 500,-46532.9304; 502,-46919.4968; 504,-47016.1384; 506,-47499.3464;
          508,-47837.592; 510,-48320.8; 512,-47837.592; 514,-48175.8376; 516,-46871.176;
          518,-46581.2512; 520,-46967.8176; 522,-47016.1384; 524,-47789.2712;
          526,-47644.3088; 528,-47306.0632; 530,-47595.988; 532,-48030.8752;
          534,-47934.2336; 536,-47644.3088; 538,-46532.9304; 540,-47595.988;
          542,-46339.6472; 544,-47499.3464; 546,-46581.2512; 548,-46726.2136;
          550,-46871.176; 552,-47644.3088; 554,-47016.1384; 556,-47740.9504;
          558,-47016.1384; 560,-47209.4216; 562,-46581.2512; 564,-45228.2688;
          566,-45566.5144; 568,-44455.136; 570,-45469.8728; 572,-44986.6648;
          574,-44745.0608])                  "#1负荷"
      annotation (Placement(transformation(extent={{32,88},{52,108}})));
    Modelica.Blocks.Sources.RealExpression realExpression2(y=time/3600)
      annotation (Placement(transformation(extent={{54,64},{34,84}})));
    User user1(
      Length=50,
      Diameter(displayUnit="mm") = 0.05,
      mflow_start=1)
      annotation (Placement(transformation(extent={{88,-62},{108,-82}})));
    Modelica.Fluid.Valves.ValveIncompressible valveIncompressible1(
      redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater,
      dp_nominal=30000,
      m_flow_nominal=3.5,
      redeclare function valveCharacteristic =
          Modelica.Fluid.Valves.BaseClasses.ValveCharacteristics.equalPercentage)
      annotation (Placement(transformation(
          extent={{10,-10},{-10,10}},
          rotation=0,
          origin={112,-44})));
    Modelica.Blocks.Sources.Constant const1(k=0.749560)
      annotation (Placement(transformation(extent={{88,-24},{108,-4}})));
    Modelica.Fluid.Sensors.Pressure pressure5(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{54,-84},{34,-104}})));
    Modelica.Fluid.Sensors.Temperature temperature(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{106,-88},{126,-108}})));
    Modelica.Blocks.Sources.RealExpression realExpression1(y=time/3600)
      annotation (Placement(transformation(extent={{-120,28},{-100,48}})));
    Modelica.Blocks.Tables.CombiTable1Ds Tg1(table=[0,-41604.2088; 2,-42473.9832;
          4,-43005.512; 6,-43826.9656; 8,-43633.6824; 10,-43826.9656; 12,-44503.4568;
          14,-41024.3592; 16,-39478.0936; 18,-38270.0736; 20,-36240.6; 22,-36965.412;
          24,-41507.5672; 26,-44600.0984; 28,-41990.7752; 30,-42570.6248; 32,-39284.8104;
          34,-41604.2088; 36,-40299.5472; 38,-40009.6224; 40,-39139.848; 42,-36820.4496;
          44,-37158.6952; 46,-39236.4896; 48,-39478.0936; 50,-39429.7728; 52,-39623.056;
          54,-39671.3768; 56,-40009.6224; 58,-41507.5672; 60,-41121.0008; 62,-40831.076;
          64,-40154.5848; 66,-39429.7728; 68,-41362.6048; 70,-41217.6424; 72,-40831.076;
          74,-42135.7376; 76,-41265.9632; 78,-41362.6048; 80,-41024.3592; 82,-39526.4144;
          84,-37738.5448; 86,-39623.056; 88,-39478.0936; 90,-38270.0736; 92,-38125.1112;
          94,-38898.244; 96,-38318.3944; 98,-39236.4896; 100,-39574.7352; 102,-39768.0184;
          104,-44455.136; 106,-43053.8328; 108,-43343.7576; 110,-39719.6976;
          112,-38656.64; 114,-38511.6776; 116,-39478.0936; 118,-39284.8104; 120,
          -38849.9232; 122,-39091.5272; 124,-39526.4144; 126,-38656.64; 128,-37448.62;
          130,-34356.0888; 132,-34694.3344; 134,-31940.0488; 136,-33824.56; 138,
          -33921.2016; 140,-32809.8232; 142,-33244.7104; 144,-32423.2568; 146,-33486.3144;
          148,-33631.2768; 150,-33582.956; 152,-33582.956; 154,-30683.708; 156,
          -27736.1392; 158,-25223.4576; 160,-26673.0816; 162,-30973.6328; 164,-27542.856;
          166,-26624.7608; 168,-27687.8184; 170,-27977.7432; 172,-27687.8184;
          174,-27301.252; 176,-29330.7256; 178,-31021.9536; 180,-25223.4576;
          182,-24208.7208; 184,-26576.44; 186,-25368.42; 188,-26431.4776; 190,-25416.7408;
          192,-26963.0064; 194,-25561.7032; 196,-25706.6656; 198,-26383.1568;
          200,-27059.648; 202,-30490.4248; 204,-31070.2744; 206,-31070.2744;
          208,-33293.0312; 210,-34259.4472; 212,-35998.996; 214,-37158.6952;
          216,-36868.7704; 218,-36917.0912; 220,-36288.9208; 222,-38173.432;
          224,-41362.6048; 226,-41845.8128; 228,-41797.492; 230,-40444.5096;
          232,-42763.908; 234,-44068.5696; 236,-43247.116; 238,-44261.8528; 240,
          -43633.6824; 242,-43778.6448; 244,-44261.8528; 246,-43247.116; 248,-41314.284;
          250,-43730.324; 252,-42715.5872; 254,-41362.6048; 256,-41169.3216;
          258,-43971.928; 260,-41652.5296; 262,-42039.096; 264,-40782.7552; 266,
          -43247.116; 268,-41604.2088; 270,-43537.0408; 272,-41652.5296; 274,-42087.4168;
          276,-41362.6048; 278,-38994.8856; 280,-40782.7552; 282,-39284.8104;
          284,-38801.6024; 286,-39284.8104; 288,-40299.5472; 290,-40057.9432;
          292,-39671.3768; 294,-39768.0184; 296,-40009.6224; 298,-40396.1888;
          300,-38366.7152; 302,-38753.2816; 304,-38608.3192; 306,-38511.6776;
          308,-39043.2064; 310,-39381.452; 312,-38656.64; 314,-38704.9608; 316,
          -39139.848; 318,-39768.0184; 320,-40009.6224; 322,-38801.6024; 324,-38946.5648;
          326,-39574.7352; 328,-37738.5448; 330,-37400.2992; 332,-37448.62; 334,
          -37641.9032; 336,-37641.9032; 338,-37351.9784; 340,-37255.3368; 342,-37641.9032;
          344,-39139.848; 346,-37931.828; 348,-38318.3944; 350,-37496.9408; 352,
          -41410.9256; 354,-40879.3968; 356,-42039.096; 358,-40106.264; 360,-40831.076;
          362,-41072.68; 364,-41024.3592; 366,-41652.5296; 368,-41749.1712; 370,
          -42135.7376; 372,-42473.9832; 374,-44165.2112; 376,-46146.364; 378,-49093.9328;
          380,-47257.7424; 382,-47595.988; 384,-47257.7424; 386,-47885.9128;
          388,-47306.0632; 390,-48079.196; 392,-48272.4792; 394,-48997.2912;
          396,-48369.1208; 398,-48175.8376; 400,-47789.2712; 402,-48175.8376;
          404,-48224.1584; 406,-47934.2336; 408,-47934.2336; 410,-48272.4792;
          412,-49045.612; 414,-48465.7624; 416,-50108.6696; 418,-51220.048; 420,
          -50398.5944; 422,-49770.424; 424,-48079.196; 426,-49190.5744; 428,-50301.9528;
          430,-50108.6696; 432,-50736.84; 434,-50060.3488; 436,-50543.5568; 438,
          -50688.5192; 440,-51268.3688; 442,-51026.7648; 444,-51171.7272; 446,-51413.3312;
          448,-50978.444; 450,-51461.652; 452,-53249.5216; 454,-52283.1056; 456,
          -52573.0304; 458,-53201.2008; 460,-52476.3888; 462,-52814.6344; 464,-53007.9176;
          466,-50833.4816; 468,-49335.5368; 470,-48127.5168; 472,-49625.4616;
          474,-49625.4616; 476,-49480.4992; 478,-49432.1784; 480,-49770.424;
          482,-49432.1784; 484,-49577.1408; 486,-49770.424; 488,-49625.4616;
          490,-49528.82; 492,-47692.6296; 494,-47740.9504; 496,-47934.2336; 498,
          -47402.7048; 500,-46532.9304; 502,-46919.4968; 504,-47016.1384; 506,-47499.3464;
          508,-47837.592; 510,-48320.8; 512,-47837.592; 514,-48175.8376; 516,-46871.176;
          518,-46581.2512; 520,-46967.8176; 522,-47016.1384; 524,-47789.2712;
          526,-47644.3088; 528,-47306.0632; 530,-47595.988; 532,-48030.8752;
          534,-47934.2336; 536,-47644.3088; 538,-46532.9304; 540,-47595.988;
          542,-46339.6472; 544,-47499.3464; 546,-46581.2512; 548,-46726.2136;
          550,-46871.176; 552,-47644.3088; 554,-47016.1384; 556,-47740.9504;
          558,-47016.1384; 560,-47209.4216; 562,-46581.2512; 564,-45228.2688;
          566,-45566.5144; 568,-44455.136; 570,-45469.8728; 572,-44986.6648;
          574,-44745.0608])                             "供水温度"
      annotation (Placement(transformation(extent={{-84,28},{-64,48}})));
    Modelica.Blocks.Math.Gain gain(k=750/3.6/50)
      annotation (Placement(transformation(extent={{-50,28},{-30,48}})));
    Modelica.Blocks.Tables.CombiTable1Ds F1oad1(table=[0,-208021.044; 2,-212369.916;
          4,-215027.56; 6,-219134.828; 8,-218168.412; 10,-219134.828; 12,-222517.284;
          14,-205121.796; 16,-197390.468; 18,-191350.368; 20,-181203; 22,-184827.06;
          24,-207537.836; 26,-223000.492; 28,-209953.876; 30,-212853.124; 32,-196424.052;
          34,-208021.044; 36,-201497.736; 38,-200048.112; 40,-195699.24; 42,-184102.248;
          44,-185793.476; 46,-196182.448; 48,-197390.468; 50,-197148.864; 52,-198115.28;
          54,-198356.884; 56,-200048.112; 58,-207537.836; 60,-205605.004; 62,-204155.38;
          64,-200772.924; 66,-197148.864; 68,-206813.024; 70,-206088.212; 72,-204155.38;
          74,-210678.688; 76,-206329.816; 78,-206813.024; 80,-205121.796; 82,-197632.072;
          84,-188692.724; 86,-198115.28; 88,-197390.468; 90,-191350.368; 92,-190625.556;
          94,-194491.22; 96,-191591.972; 98,-196182.448; 100,-197873.676; 102,-198840.092;
          104,-222275.68; 106,-215269.164; 108,-216718.788; 110,-198598.488;
          112,-193283.2; 114,-192558.388; 116,-197390.468; 118,-196424.052; 120,
          -194249.616; 122,-195457.636; 124,-197632.072; 126,-193283.2; 128,-187243.1;
          130,-171780.444; 132,-173471.672; 134,-159700.244; 136,-169122.8; 138,
          -169606.008; 140,-164049.116; 142,-166223.552; 144,-162116.284; 146,-167431.572;
          148,-168156.384; 150,-167914.78; 152,-167914.78; 154,-153418.54; 156,
          -138680.696; 158,-126117.288; 160,-133365.408; 162,-154868.164; 164,-137714.28;
          166,-133123.804; 168,-138439.092; 170,-139888.716; 172,-138439.092;
          174,-136506.26; 176,-146653.628; 178,-155109.768; 180,-126117.288;
          182,-121043.604; 184,-132882.2; 186,-126842.1; 188,-132157.388; 190,-127083.704;
          192,-134815.032; 194,-127808.516; 196,-128533.328; 198,-131915.784;
          200,-135298.24; 202,-152452.124; 204,-155351.372; 206,-155351.372;
          208,-166465.156; 210,-171297.236; 212,-179994.98; 214,-185793.476;
          216,-184343.852; 218,-184585.456; 220,-181444.604; 222,-190867.16;
          224,-206813.024; 226,-209229.064; 228,-208987.46; 230,-202222.548;
          232,-213819.54; 234,-220342.848; 236,-216235.58; 238,-221309.264; 240,
          -218168.412; 242,-218893.224; 244,-221309.264; 246,-216235.58; 248,-206571.42;
          250,-218651.62; 252,-213577.936; 254,-206813.024; 256,-205846.608;
          258,-219859.64; 260,-208262.648; 262,-210195.48; 264,-203913.776; 266,
          -216235.58; 268,-208021.044; 270,-217685.204; 272,-208262.648; 274,-210437.084;
          276,-206813.024; 278,-194974.428; 280,-203913.776; 282,-196424.052;
          284,-194008.012; 286,-196424.052; 288,-201497.736; 290,-200289.716;
          292,-198356.884; 294,-198840.092; 296,-200048.112; 298,-201980.944;
          300,-191833.576; 302,-193766.408; 304,-193041.596; 306,-192558.388;
          308,-195216.032; 310,-196907.26; 312,-193283.2; 314,-193524.804; 316,
          -195699.24; 318,-198840.092; 320,-200048.112; 322,-194008.012; 324,-194732.824;
          326,-197873.676; 328,-188692.724; 330,-187001.496; 332,-187243.1; 334,
          -188209.516; 336,-188209.516; 338,-186759.892; 340,-186276.684; 342,-188209.516;
          344,-195699.24; 346,-189659.14; 348,-191591.972; 350,-187484.704; 352,
          -207054.628; 354,-204396.984; 356,-210195.48; 358,-200531.32; 360,-204155.38;
          362,-205363.4; 364,-205121.796; 366,-208262.648; 368,-208745.856; 370,
          -210678.688; 372,-212369.916; 374,-220826.056; 376,-230731.82; 378,-245469.664;
          380,-236288.712; 382,-237979.94; 384,-236288.712; 386,-239429.564;
          388,-236530.316; 390,-240395.98; 392,-241362.396; 394,-244986.456;
          396,-241845.604; 398,-240879.188; 400,-238946.356; 402,-240879.188;
          404,-241120.792; 406,-239671.168; 408,-239671.168; 410,-241362.396;
          412,-245228.06; 414,-242328.812; 416,-250543.348; 418,-256100.24; 420,
          -251992.972; 422,-248852.12; 424,-240395.98; 426,-245952.872; 428,-251509.764;
          430,-250543.348; 432,-253684.2; 434,-250301.744; 436,-252717.784; 438,
          -253442.596; 440,-256341.844; 442,-255133.824; 444,-255858.636; 446,-257066.656;
          448,-254892.22; 450,-257308.26; 452,-266247.608; 454,-261415.528; 456,
          -262865.152; 458,-266006.004; 460,-262381.944; 462,-264073.172; 464,-265039.588;
          466,-254167.408; 468,-246677.684; 470,-240637.584; 472,-248127.308;
          474,-248127.308; 476,-247402.496; 478,-247160.892; 480,-248852.12;
          482,-247160.892; 484,-247885.704; 486,-248852.12; 488,-248127.308;
          490,-247644.1; 492,-238463.148; 494,-238704.752; 496,-239671.168; 498,
          -237013.524; 500,-232664.652; 502,-234597.484; 504,-235080.692; 506,-237496.732;
          508,-239187.96; 510,-241604; 512,-239187.96; 514,-240879.188; 516,-234355.88;
          518,-232906.256; 520,-234839.088; 522,-235080.692; 524,-238946.356;
          526,-238221.544; 528,-236530.316; 530,-237979.94; 532,-240154.376;
          534,-239671.168; 536,-238221.544; 538,-232664.652; 540,-237979.94;
          542,-231698.236; 544,-237496.732; 546,-232906.256; 548,-233631.068;
          550,-234355.88; 552,-238221.544; 554,-235080.692; 556,-238704.752;
          558,-235080.692; 560,-236047.108; 562,-232906.256; 564,-226141.344;
          566,-227832.572; 568,-222275.68; 570,-227349.364; 572,-224933.324;
          574,-223725.304])                  "#1负荷"
      annotation (Placement(transformation(extent={{72,-124},{92,-104}})));
    Modelica.Blocks.Sources.RealExpression realExpression3(y=time/3600)
      annotation (Placement(transformation(extent={{88,-152},{68,-132}})));
    Modelica.Fluid.Sensors.Temperature temperature1(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{4,-62},{24,-82}})));
    Modelica.Fluid.Sensors.MassFlowRate massFlowRate(redeclare package Medium =
          Modelica.Media.Water.ConstantPropertyLiquidWater)
      annotation (Placement(transformation(extent={{130,-82},{150,-62}})));
  equation
    connect(boundary.ports[1], pump.port_a) annotation (Line(points={{-54,2},{
            -44,2},{-44,4},{-34,4}}, color={0,127,255}));
    connect(pump.port_b, pipe.port_a) annotation (Line(points={{-14,4},{4,4},{4,
            2},{20,2}}, color={0,127,255}));
    connect(pipe.port_b1, boundary1.ports[1]) annotation (Line(points={{20,-2},
            {0,-2},{0,-54},{-52,-54}}, color={0,127,255}));
    connect(Tg.u,realExpression13. y)
      annotation (Line(points={{-112,-2},{-119,-2}},
                                                   color={0,0,127}));
    connect(Tg.y[1], boundary.T_in)
      annotation (Line(points={{-89,-2},{-76,-2}}, color={0,0,127}));
    connect(pipe.port_b, pipe1.port_a)
      annotation (Line(points={{40,2},{64,2},{64,18}}, color={0,127,255}));
    connect(pipe1.port_b1, pipe.port_a1)
      annotation (Line(points={{68,18},{68,-2},{40,-2}}, color={0,127,255}));
    connect(pipe.port_b, pipe2.port_a)
      annotation (Line(points={{40,2},{64,2},{64,-22}}, color={0,127,255}));
    connect(pipe.port_a1, pipe2.port_b1)
      annotation (Line(points={{40,-2},{68,-2},{68,-22}}, color={0,127,255}));
    connect(pipe1.port_b, F1.port_a)
      annotation (Line(points={{64,38},{64,70},{76,70}}, color={0,127,255}));
    connect(F1.port_b, valveIncompressible16.port_a) annotation (Line(points={{
            96,70},{144,70},{144,52},{130,52}}, color={0,127,255}));
    connect(valveIncompressible16.port_b, pipe1.port_a1)
      annotation (Line(points={{110,52},{68,52},{68,38}}, color={0,127,255}));
    connect(const.y, valveIncompressible16.opening)
      annotation (Line(points={{109,28},{120,28},{120,44}}, color={0,0,127}));
    connect(F1oad.u,realExpression2. y) annotation (Line(points={{30,98},{22,98},
            {22,74},{33,74}},          color={0,0,127}));
    connect(F1oad.y[1], F1.Q)
      annotation (Line(points={{53,98},{86,98},{86,76}}, color={0,0,127}));
    connect(pipe2.port_b, user1.port_a) annotation (Line(points={{64,-42},{64,
            -72},{88,-72}}, color={0,127,255}));
    connect(valveIncompressible1.port_b, pipe2.port_a1) annotation (Line(points
          ={{102,-44},{68,-44},{68,-42}}, color={0,127,255}));
    connect(const1.y, valveIncompressible1.opening) annotation (Line(points={{
            109,-14},{112,-14},{112,-36}}, color={0,0,127}));
    connect(pressure5.port, pipe2.port_b) annotation (Line(points={{44,-84},{44,
            -72},{64,-72},{64,-42}}, color={0,127,255}));
    connect(temperature.port, user1.port_b) annotation (Line(points={{116,-88},
            {116,-72},{108,-72}}, color={0,127,255}));
    connect(Tg1.u, realExpression1.y)
      annotation (Line(points={{-86,38},{-99,38}}, color={0,0,127}));
    connect(Tg1.y[1], gain.u)
      annotation (Line(points={{-63,38},{-52,38}}, color={0,0,127}));
    connect(F1oad1.u, realExpression3.y) annotation (Line(points={{70,-114},{62,
            -114},{62,-142},{67,-142}}, color={0,0,127}));
    connect(F1oad1.y[1], user1.Q) annotation (Line(points={{93,-114},{98,-114},
            {98,-78}}, color={0,0,127}));
    connect(temperature1.port, user1.port_a) annotation (Line(points={{14,-62},
            {14,-58},{64,-58},{64,-72},{88,-72}}, color={0,127,255}));
    connect(user1.port_b, massFlowRate.port_a)
      annotation (Line(points={{108,-72},{130,-72}}, color={0,127,255}));
    connect(massFlowRate.port_b, valveIncompressible1.port_a) annotation (Line(
          points={{150,-72},{158,-72},{158,-44},{122,-44}}, color={0,127,255}));
    annotation (
      Icon(coordinateSystem(preserveAspectRatio=false, extent={{-140,-160},{160,
              100}}), graphics={
          Ellipse(lineColor = {75,138,73},
                  fillColor={255,255,255},
                  fillPattern = FillPattern.Solid,
                  extent={{-102,-96},{98,104}}),
          Polygon(lineColor = {0,0,255},
                  fillColor = {75,138,73},
                  pattern = LinePattern.None,
                  fillPattern = FillPattern.Solid,
                  points={{-38,64},{62,4},{-38,-56},{-38,64}})}),
      Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-140,-160},{
              160,100}})),
      experiment(
        StopTime=86400,
        Interval=3600,
        __Dymola_Algorithm="Dassl"));
  end test;
  annotation (uses(Modelica(version="4.0.0")));
end HeatingNetwork_20250316;
