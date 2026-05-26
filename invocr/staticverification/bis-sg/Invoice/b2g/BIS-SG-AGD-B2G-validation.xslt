<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:svrl="http://purl.oclc.org/dsdl/svrl" 
                xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" 
                xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" 
                xmlns:ubl="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
                xmlns:cn="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                version="2.0">

    <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="yes"/>


    <!-- ==================== -->
    <!-- Business Unit 代码列表 (优化版本 - 使用变量+Key索引，避免StackOverflow) -->
    <!-- Total 2675 valid Business Unit codes from MinistryBoard.xls and MinistryBoard-NonPayNow.xls -->
    <!-- Includes: 359 numeric codes (4-digit), 119 letter codes (3-letter), 2197 alphanumeric codes -->
    <!-- ==================== -->
    <xsl:variable name="valid-business-units">
        <units>
            <unit>2601</unit><unit>2603</unit><unit>2606</unit><unit>2607</unit><unit>2608</unit><unit>2609</unit><unit>2610</unit><unit>2611</unit>
            <unit>2612</unit><unit>2613</unit><unit>2615</unit><unit>2616</unit><unit>2617</unit><unit>2618</unit><unit>2620</unit><unit>2621</unit>
            <unit>2623</unit><unit>2624</unit><unit>2627</unit><unit>2629</unit><unit>2630</unit><unit>2634</unit><unit>2637</unit><unit>2649</unit>
            <unit>2652</unit><unit>2653</unit><unit>2656</unit><unit>2658</unit><unit>2659</unit><unit>2901</unit><unit>2902</unit><unit>2903</unit>
            <unit>2904</unit><unit>9002</unit><unit>9004</unit><unit>9005</unit><unit>9007</unit><unit>9012</unit><unit>9014</unit><unit>9016</unit>
            <unit>9021</unit><unit>9022</unit><unit>9023</unit><unit>9024</unit><unit>9025</unit><unit>9027</unit><unit>9028</unit><unit>9029</unit>
            <unit>9034</unit><unit>9035</unit><unit>9036</unit><unit>9037</unit><unit>9038</unit><unit>9039</unit><unit>9042</unit><unit>9043</unit>
            <unit>9049</unit><unit>9052</unit><unit>9054</unit><unit>9055</unit><unit>9057</unit><unit>9069</unit><unit>9070</unit><unit>9073</unit>
            <unit>9075</unit><unit>9076</unit><unit>9078</unit><unit>9079</unit><unit>9080</unit><unit>9081</unit><unit>9082</unit><unit>9083</unit>
            <unit>9084</unit><unit>9085</unit><unit>9089</unit><unit>9090</unit><unit>9092</unit><unit>9095</unit><unit>9097</unit><unit>9099</unit>
            <unit>9101</unit><unit>9103</unit><unit>9104</unit><unit>9105</unit><unit>9106</unit><unit>9112</unit><unit>9114</unit><unit>9117</unit>
            <unit>9119</unit><unit>9120</unit><unit>9130</unit><unit>9132</unit><unit>9134</unit><unit>9137</unit><unit>9143</unit><unit>9145</unit>
            <unit>9147</unit><unit>9152</unit><unit>9153</unit><unit>9154</unit><unit>9155</unit><unit>9156</unit><unit>9157</unit><unit>9158</unit>
            <unit>9159</unit><unit>9160</unit><unit>9161</unit><unit>9164</unit><unit>9166</unit><unit>9168</unit><unit>9170</unit><unit>9171</unit>
            <unit>9172</unit><unit>9173</unit><unit>9174</unit><unit>9175</unit><unit>9176</unit><unit>9177</unit><unit>9178</unit><unit>9179</unit>
            <unit>9182</unit><unit>9183</unit><unit>9184</unit><unit>9185</unit><unit>9186</unit><unit>9187</unit><unit>9188</unit><unit>9189</unit>
            <unit>9190</unit><unit>9192</unit><unit>9193</unit><unit>9196</unit><unit>9197</unit><unit>9199</unit><unit>9202</unit><unit>9204</unit>
            <unit>9205</unit><unit>9206</unit><unit>9207</unit><unit>9208</unit><unit>9209</unit><unit>9210</unit><unit>9211</unit><unit>9212</unit>
            <unit>9213</unit><unit>9214</unit><unit>9215</unit><unit>9216</unit><unit>9217</unit><unit>9218</unit><unit>9219</unit><unit>9220</unit>
            <unit>9222</unit><unit>9223</unit><unit>9224</unit><unit>9225</unit><unit>9226</unit><unit>9227</unit><unit>9228</unit><unit>9230</unit>
            <unit>9231</unit><unit>9232</unit><unit>9233</unit><unit>9234</unit><unit>9235</unit><unit>9236</unit><unit>9239</unit><unit>9240</unit>
            <unit>9241</unit><unit>9301</unit><unit>9302</unit><unit>9306</unit><unit>9310</unit><unit>9311</unit><unit>9312</unit><unit>9313</unit>
            <unit>9314</unit><unit>9315</unit><unit>9317</unit><unit>9318</unit><unit>9319</unit><unit>9320</unit><unit>9331</unit><unit>9341</unit>
            <unit>9343</unit><unit>9344</unit><unit>9361</unit><unit>9362</unit><unit>9363</unit><unit>9371</unit><unit>9372</unit><unit>9373</unit>
            <unit>9374</unit><unit>9375</unit><unit>9376</unit><unit>9377</unit><unit>9378</unit><unit>9379</unit><unit>9380</unit><unit>9381</unit>
            <unit>9382</unit><unit>9383</unit><unit>9384</unit><unit>9391</unit><unit>9401</unit><unit>9402</unit><unit>9404</unit><unit>9405</unit>
            <unit>9406</unit><unit>9407</unit><unit>9408</unit><unit>9409</unit><unit>9410</unit><unit>9412</unit><unit>9413</unit><unit>9501</unit>
            <unit>9502</unit><unit>9503</unit><unit>9505</unit><unit>9506</unit><unit>9508</unit><unit>9510</unit><unit>9511</unit><unit>9512</unit>
            <unit>9513</unit><unit>9515</unit><unit>9516</unit><unit>9518</unit><unit>9519</unit><unit>9520</unit><unit>9523</unit><unit>9524</unit>
            <unit>9528</unit><unit>9529</unit><unit>9531</unit><unit>9533</unit><unit>9535</unit><unit>9536</unit><unit>9537</unit><unit>9538</unit>
            <unit>9539</unit><unit>9540</unit><unit>9541</unit><unit>9543</unit><unit>9545</unit><unit>9548</unit><unit>9549</unit><unit>9550</unit>
            <unit>9556</unit><unit>9561</unit><unit>9563</unit><unit>9565</unit><unit>9566</unit><unit>9569</unit><unit>9570</unit><unit>9572</unit>
            <unit>9573</unit><unit>9574</unit><unit>9575</unit><unit>9576</unit><unit>9577</unit><unit>9580</unit><unit>9581</unit><unit>9582</unit>
            <unit>9583</unit><unit>9592</unit><unit>9593</unit><unit>9596</unit><unit>9597</unit><unit>9598</unit><unit>9600</unit><unit>9601</unit>
            <unit>9610</unit><unit>9611</unit><unit>9612</unit><unit>9613</unit><unit>9615</unit><unit>9617</unit><unit>9619</unit><unit>9620</unit>
            <unit>9621</unit><unit>9622</unit><unit>9625</unit><unit>9626</unit><unit>9627</unit><unit>9629</unit><unit>9630</unit><unit>9631</unit>
            <unit>9633</unit><unit>9637</unit><unit>9638</unit><unit>9640</unit><unit>9641</unit><unit>9644</unit><unit>9646</unit><unit>9651</unit>
            <unit>9653</unit><unit>9660</unit><unit>9662</unit><unit>9663</unit><unit>9664</unit><unit>9666</unit><unit>9667</unit><unit>9668</unit>
            <unit>9669</unit><unit>9680</unit><unit>9681</unit><unit>9682</unit><unit>9683</unit><unit>9684</unit><unit>9685</unit><unit>9686</unit>
            <unit>9687</unit><unit>9688</unit><unit>9701</unit><unit>9702</unit><unit>9703</unit><unit>9711</unit><unit>9712</unit><unit>9713</unit>
            <unit>9714</unit><unit>9715</unit><unit>9721</unit><unit>9731</unit><unit>9732</unit><unit>9733</unit><unit>9741</unit><unit>9742</unit>
            <unit>9751</unit><unit>9752</unit><unit>9754</unit><unit>9755</unit><unit>9757</unit><unit>9761</unit><unit>9762</unit><unit>9771</unit>
            <unit>9772</unit><unit>9773</unit><unit>9774</unit><unit>9775</unit><unit>9776</unit><unit>9777</unit><unit>9778</unit><unit>9780</unit>
            <unit>9791</unit><unit>9803</unit><unit>9807</unit><unit>9808</unit><unit>9817</unit><unit>9818</unit><unit>9819</unit><unit>9820</unit>
            <unit>9821</unit><unit>9822</unit><unit>9831</unit><unit>9832</unit><unit>9834</unit><unit>9835</unit><unit>9999</unit><unit>ACC</unit>
            <unit>ACR</unit><unit>ACR01</unit><unit>AGC</unit><unit>AGC01</unit><unit>AIC</unit><unit>AMF</unit><unit>AUD</unit><unit>AUD01</unit>
            <unit>AVC</unit><unit>AZA</unit><unit>BBI</unit><unit>BCA</unit><unit>BCA01</unit><unit>BDH</unit><unit>BER</unit><unit>BIC</unit>
            <unit>BII</unit><unit>BIP</unit><unit>BOA</unit><unit>BOA01</unit><unit>BRC</unit><unit>BTI</unit><unit>CAA</unit><unit>CAA01</unit>
            <unit>CAA02</unit><unit>CAA03</unit><unit>CAA04</unit><unit>CAA05</unit><unit>CAA06</unit><unit>CAA07</unit><unit>CAA08</unit><unit>CAA09</unit>
            <unit>CAA10</unit><unit>CAA11</unit><unit>CAA12</unit><unit>CAA13</unit><unit>CAA14</unit><unit>CAA15</unit><unit>CAA17</unit><unit>CAA18</unit>
            <unit>CAA19</unit><unit>CAA20</unit><unit>CAA21</unit><unit>CAA22</unit><unit>CAA23</unit><unit>CAA24</unit><unit>CAA25</unit><unit>CAA26</unit>
            <unit>CAA27</unit><unit>CAA28</unit><unit>CAA29</unit><unit>CAA30</unit><unit>CAA31</unit><unit>CAA32</unit><unit>CAA33</unit><unit>CAA34</unit>
            <unit>CAA35</unit><unit>CAA36</unit><unit>CAA37</unit><unit>CAA38</unit><unit>CAB</unit><unit>CAB01</unit><unit>CCL</unit><unit>CCY</unit>
            <unit>CCY01</unit><unit>CCY02</unit><unit>CCY03</unit><unit>CDA</unit><unit>CDA01</unit><unit>CDA02</unit><unit>CDA03</unit><unit>CDA04</unit>
            <unit>CDA05</unit><unit>CDA06</unit><unit>CDA07</unit><unit>CDA08</unit><unit>CDA09</unit><unit>CDA10</unit><unit>CDA11</unit><unit>CDA12</unit>
            <unit>CDA13</unit><unit>CDA14</unit><unit>CDA15</unit><unit>CDA16</unit><unit>CDA17</unit><unit>CDA18</unit><unit>CDA19</unit><unit>CDA20</unit>
            <unit>CDA21</unit><unit>CDA22</unit><unit>CDA23</unit><unit>CDA24</unit><unit>CDA25</unit><unit>CDA26</unit><unit>CDA27</unit><unit>CDA28</unit>
            <unit>CDA29</unit><unit>CDA30</unit><unit>CDA31</unit><unit>CDA32</unit><unit>CDA33</unit><unit>CDA34</unit><unit>CEA</unit><unit>CEA01</unit>
            <unit>CEI</unit><unit>CEO</unit><unit>CEO03</unit><unit>CES</unit><unit>COM</unit><unit>COM01</unit><unit>CPF</unit><unit>CPF01</unit>
            <unit>CPF03</unit><unit>CPF06</unit><unit>CPF07</unit><unit>CPF08</unit><unit>CPF11</unit><unit>CPF15</unit><unit>CPF18</unit><unit>CPF19</unit>
            <unit>CPF21</unit><unit>CPF23</unit><unit>CPF24</unit><unit>CPF25</unit><unit>CPF26</unit><unit>CPF27</unit><unit>CPF28</unit><unit>CPF29</unit>
            <unit>CPF30</unit><unit>CPF31</unit><unit>CPF32</unit><unit>CPF33</unit><unit>CPF34</unit><unit>CPF35</unit><unit>CPF36</unit><unit>CPF37</unit>
            <unit>CPF38</unit><unit>CPF39</unit><unit>CPF40</unit><unit>CPF41</unit><unit>CPF42</unit><unit>CPF43</unit><unit>CPF44</unit><unit>CPF45</unit>
            <unit>CPF48</unit><unit>CPF49</unit><unit>CPF50</unit><unit>CPF51</unit><unit>CPF52</unit><unit>CPF53</unit><unit>CPF54</unit><unit>CPF55</unit>
            <unit>CPF56</unit><unit>CPF58</unit><unit>CPF59</unit><unit>CPF60</unit><unit>CPF61</unit><unit>CPF62</unit><unit>CPF63</unit><unit>CPF64</unit>
            <unit>CPF65</unit><unit>CPF66</unit><unit>CPF67</unit><unit>CPF68</unit><unit>CPF69</unit><unit>CPF70</unit><unit>CPF71</unit><unit>CPF72</unit>
            <unit>CPF73</unit><unit>CPF76</unit><unit>CPF77</unit><unit>CPF78</unit><unit>CPF79</unit><unit>CPF80</unit><unit>CPF81</unit><unit>CPF82</unit>
            <unit>CPF88</unit><unit>CPF89</unit><unit>CPF90</unit><unit>CPF91</unit><unit>CPF92</unit><unit>CPF93</unit><unit>CPF94</unit><unit>CPF95</unit>
            <unit>CPF96</unit><unit>CPF97</unit><unit>CPF98</unit><unit>CRA</unit><unit>CRA01</unit><unit>CRC</unit><unit>CSC</unit><unit>CSC01</unit>
            <unit>CVL</unit><unit>CVL01</unit><unit>DAR</unit><unit>DCE05</unit><unit>DCE06</unit><unit>DCPF0</unit><unit>DDC</unit><unit>DDH</unit>
            <unit>DES</unit><unit>DHDB1</unit><unit>DHDB2</unit><unit>DHDB3</unit><unit>DHDB4</unit><unit>DHDB5</unit><unit>DHDB6</unit><unit>DHDB7</unit>
            <unit>DHDB8</unit><unit>DHDB9</unit><unit>DITA1</unit><unit>DITE1</unit><unit>DITE2</unit><unit>DLAW1</unit><unit>DLW15</unit><unit>DMHA1</unit>
            <unit>DMHA2</unit><unit>DMHA3</unit><unit>DMHA4</unit><unit>DMHA5</unit><unit>DMHA6</unit><unit>DMHA7</unit><unit>DMHA8</unit><unit>DMOF1</unit>
            <unit>DPMO2</unit><unit>DSI</unit><unit>DST01</unit><unit>EAT</unit><unit>EBC</unit><unit>EDB</unit><unit>EDB01</unit><unit>EDB02</unit>
            <unit>EDB03</unit><unit>EDB04</unit><unit>EDB05</unit><unit>EDB07</unit><unit>EDB08</unit><unit>EDB09</unit><unit>EDB10</unit><unit>EDB11</unit>
            <unit>EDB13</unit><unit>EDB14</unit><unit>EDB15</unit><unit>EDB17</unit><unit>EDB18</unit><unit>EDB19</unit><unit>EDB20</unit><unit>EDB21</unit>
            <unit>EDB22</unit><unit>EDB23</unit><unit>EDB24</unit><unit>EDB25</unit><unit>EDB27</unit><unit>EDB28</unit><unit>EDB29</unit><unit>EDB30</unit>
            <unit>EDB32</unit><unit>EDB33</unit><unit>EDB34</unit><unit>EDB35</unit><unit>EDB36</unit><unit>EDB37</unit><unit>EDB38</unit><unit>EDB42</unit>
            <unit>EDB43</unit><unit>EDB45</unit><unit>EDB46</unit><unit>EDB47</unit><unit>EDB49</unit><unit>EDB50</unit><unit>EDB52</unit><unit>EDB53</unit>
            <unit>EDB54</unit><unit>EDB55</unit><unit>EDB56</unit><unit>EDB57</unit><unit>EDB58</unit><unit>EDB59</unit><unit>EDB60</unit><unit>EDB61</unit>
            <unit>EDB62</unit><unit>EDF</unit><unit>EDF01</unit><unit>EDF07</unit><unit>EDF10</unit><unit>EDF11</unit><unit>EDF12</unit><unit>EDF13</unit>
            <unit>EDF15</unit><unit>EDF16</unit><unit>EDF17</unit><unit>EDF19</unit><unit>EDF20</unit><unit>EDF21</unit><unit>EDF23</unit><unit>EHQ</unit>
            <unit>EMA</unit><unit>EMA01</unit><unit>EMA03</unit><unit>EMA04</unit><unit>EMA05</unit><unit>EMA06</unit><unit>EMA07</unit><unit>EMA08</unit>
            <unit>EMA09</unit><unit>EMA10</unit><unit>EMA11</unit><unit>EMA12</unit><unit>EMA13</unit><unit>EMA14</unit><unit>EMA15</unit><unit>EMA16</unit>
            <unit>EMA17</unit><unit>EMA18</unit><unit>EMA19</unit><unit>EMA20</unit><unit>EMA21</unit><unit>EMA22</unit><unit>EMA23</unit><unit>EMA24</unit>
            <unit>EMA25</unit><unit>EMA26</unit><unit>EMA27</unit><unit>EMA28</unit><unit>EMA29</unit><unit>EMA30</unit><unit>EMA31</unit><unit>EMA32</unit>
            <unit>EMA33</unit><unit>EMA34</unit><unit>EMA35</unit><unit>EMA36</unit><unit>EMA37</unit><unit>EMA99</unit><unit>ENT</unit><unit>ENV</unit>
            <unit>ENV01</unit><unit>ENV17</unit><unit>ENV19</unit><unit>ESG</unit><unit>ESG01</unit><unit>ESG02</unit><unit>ESG03</unit><unit>FBI</unit>
            <unit>FIN</unit><unit>FIN01</unit><unit>FIN02</unit><unit>FIN03</unit><unit>FIN04</unit><unit>FOS42</unit><unit>FOS79</unit><unit>GIS</unit>
            <unit>GTC</unit><unit>GVT</unit><unit>GVT01</unit><unit>GVT02</unit><unit>GVT03</unit><unit>GVT04</unit><unit>GVT05</unit><unit>GVT06</unit>
            <unit>GVT07</unit><unit>GVT08</unit><unit>GVT09</unit><unit>GVT10</unit><unit>GVT11</unit><unit>GVT12</unit><unit>GVT13</unit><unit>GVT14</unit>
            <unit>GVT15</unit><unit>GVT16</unit><unit>GVT17</unit><unit>GVT18</unit><unit>GVT19</unit><unit>GVT20</unit><unit>GVT21</unit><unit>GVT22</unit>
            <unit>GVT23</unit><unit>GVT24</unit><unit>GVT25</unit><unit>GVT26</unit><unit>GVT27</unit><unit>GVT28</unit><unit>GVT29</unit><unit>GVT30</unit>
            <unit>GVT31</unit><unit>GVT32</unit><unit>GVT33</unit><unit>GVT34</unit><unit>GVT35</unit><unit>GVT36</unit><unit>GVT37</unit><unit>GVT38</unit>
            <unit>GVT39</unit><unit>GVT40</unit><unit>GVT41</unit><unit>GVT42</unit><unit>GVT43</unit><unit>GVT44</unit><unit>GVT45</unit><unit>GVT46</unit>
            <unit>GVT47</unit><unit>GVT48</unit><unit>GVT49</unit><unit>GVT50</unit><unit>GVT51</unit><unit>GVT52</unit><unit>GVT53</unit><unit>GVT54</unit>
            <unit>GVT55</unit><unit>GVT56</unit><unit>GVT57</unit><unit>GVT58</unit><unit>GVT59</unit><unit>GVT60</unit><unit>GVT61</unit><unit>GVT62</unit>
            <unit>GVT63</unit><unit>GVT64</unit><unit>GVT65</unit><unit>GVT66</unit><unit>GVT67</unit><unit>GVT68</unit><unit>GVT69</unit><unit>GVT70</unit>
            <unit>GVT71</unit><unit>GVT72</unit><unit>GVT73</unit><unit>GVT74</unit><unit>GVT76</unit><unit>GVT77</unit><unit>GVT78</unit><unit>GVT79</unit>
            <unit>GVT80</unit><unit>GVT81</unit><unit>GVT82</unit><unit>GVT83</unit><unit>GVT84</unit><unit>GVT85</unit><unit>GVT86</unit><unit>GVT87</unit>
            <unit>GVT88</unit><unit>GVT89</unit><unit>GVT90</unit><unit>GVT91</unit><unit>GVT92</unit><unit>GVT93</unit><unit>HDB</unit><unit>HDB21</unit>
            <unit>HDB22</unit><unit>HDB24</unit><unit>HDB25</unit><unit>HDB26</unit><unit>HDB27</unit><unit>HDB28</unit><unit>HDB29</unit><unit>HDB30</unit>
            <unit>HDB31</unit><unit>HDB32</unit><unit>HDB33</unit><unit>HDB34</unit><unit>HDB35</unit><unit>HDB36</unit><unit>HDB37</unit><unit>HDB38</unit>
            <unit>HDB39</unit><unit>HDB40</unit><unit>HDB41</unit><unit>HDB42</unit><unit>HDB43</unit><unit>HDB44</unit><unit>HDB45</unit><unit>HDB46</unit>
            <unit>HDB48</unit><unit>HDB49</unit><unit>HDB50</unit><unit>HDB51</unit><unit>HDB52</unit><unit>HDB53</unit><unit>HDB54</unit><unit>HDB55</unit>
            <unit>HDB56</unit><unit>HDB57</unit><unit>HDB58</unit><unit>HDB59</unit><unit>HDB60</unit><unit>HDB61</unit><unit>HDB62</unit><unit>HDB64</unit>
            <unit>HDB65</unit><unit>HDB66</unit><unit>HDB67</unit><unit>HDB68</unit><unit>HDB69</unit><unit>HDB70</unit><unit>HDB74</unit><unit>HDB75</unit>
            <unit>HDB76</unit><unit>HDB77</unit><unit>HDB78</unit><unit>HDB79</unit><unit>HDB80</unit><unit>HDB81</unit><unit>HDB82</unit><unit>HDB83</unit>
            <unit>HDB84</unit><unit>HDP</unit><unit>HPB</unit><unit>HPB02</unit><unit>HPB03</unit><unit>HPB04</unit><unit>HPB05</unit><unit>HPB06</unit>
            <unit>HPB07</unit><unit>HPB09</unit><unit>HPB10</unit><unit>HPB11</unit><unit>HPB12</unit><unit>HPB13</unit><unit>HPB14</unit><unit>HPB15</unit>
            <unit>HPB16</unit><unit>HPB17</unit><unit>HPB18</unit><unit>HPB19</unit><unit>HPB20</unit><unit>HPB21</unit><unit>HPB22</unit><unit>HPB23</unit>
            <unit>HPB24</unit><unit>HPB25</unit><unit>HPB26</unit><unit>HPB27</unit><unit>HPB29</unit><unit>HPB30</unit><unit>HPB31</unit><unit>HPB32</unit>
            <unit>HPB33</unit><unit>HPB34</unit><unit>HPB35</unit><unit>HPB36</unit><unit>HPB37</unit><unit>HPB38</unit><unit>HPB39</unit><unit>HPB40</unit>
            <unit>HPB41</unit><unit>HPB42</unit><unit>HPB45</unit><unit>HPB46</unit><unit>HPB47</unit><unit>HPB48</unit><unit>HPB49</unit><unit>HPB50</unit>
            <unit>HPB51</unit><unit>HPB53</unit><unit>HPB58</unit><unit>HPB70</unit><unit>HPB71</unit><unit>HPB76</unit><unit>HPB78</unit><unit>HPB79</unit>
            <unit>HPB80</unit><unit>HPB81</unit><unit>HPB82</unit><unit>HPB83</unit><unit>HPB88</unit><unit>HPC</unit><unit>HSA</unit><unit>HSA01</unit>
            <unit>HSA02</unit><unit>HSA03</unit><unit>HSA04</unit><unit>HSA05</unit><unit>HSA06</unit><unit>HSA07</unit><unit>HSA08</unit><unit>HSA09</unit>
            <unit>HSA10</unit><unit>HSA12</unit><unit>HSA13</unit><unit>HSA14</unit><unit>HSA15</unit><unit>HSA16</unit><unit>HSA17</unit><unit>HSA18</unit>
            <unit>HSA19</unit><unit>HSA20</unit><unit>HSA21</unit><unit>HSA22</unit><unit>HSA23</unit><unit>HSA24</unit><unit>HSA25</unit><unit>HSA26</unit>
            <unit>HSA27</unit><unit>HSA28</unit><unit>HSA29</unit><unit>HSA30</unit><unit>HSA31</unit><unit>HSA32</unit><unit>HSA33</unit><unit>HSA34</unit>
            <unit>HSA35</unit><unit>HSA36</unit><unit>HSA37</unit><unit>HSA38</unit><unit>HSA39</unit><unit>HSA40</unit><unit>HSA41</unit><unit>HSA42</unit>
            <unit>HSA43</unit><unit>HSA44</unit><unit>HSA45</unit><unit>HSA46</unit><unit>HSA47</unit><unit>HSA48</unit><unit>HSA49</unit><unit>HSA50</unit>
            <unit>HSA51</unit><unit>HSA55</unit><unit>HSA56</unit><unit>HSA58</unit><unit>HSA59</unit><unit>HSA60</unit><unit>HSA61</unit><unit>HSA63</unit>
            <unit>HSA64</unit><unit>HSA65</unit><unit>HSA66</unit><unit>HSA67</unit><unit>HSA68</unit><unit>HSA69</unit><unit>HTX</unit><unit>HTX01</unit>
            <unit>IBB</unit><unit>IBN</unit><unit>ICS</unit><unit>IDD</unit><unit>IDG</unit><unit>IDL</unit><unit>IEF</unit><unit>IEF40</unit>
            <unit>IEF50</unit><unit>IEF60</unit><unit>IGN</unit><unit>IMB</unit><unit>IMD</unit><unit>IMD01</unit><unit>IMD02</unit><unit>IMD03</unit>
            <unit>IMD04</unit><unit>IMD05</unit><unit>IMD06</unit><unit>IMD07</unit><unit>IMD08</unit><unit>IMD09</unit><unit>IMD10</unit><unit>IMD11</unit>
            <unit>IMD12</unit><unit>IMD13</unit><unit>IMD14</unit><unit>IMD15</unit><unit>IMD16</unit><unit>IMD17</unit><unit>IMD18</unit><unit>IMD19</unit>
            <unit>IMD20</unit><unit>IMD21</unit><unit>IMD22</unit><unit>IMD23</unit><unit>IMD24</unit><unit>IMD25</unit><unit>IMD26</unit><unit>IMD27</unit>
            <unit>IMD28</unit><unit>IMD29</unit><unit>IMD30</unit><unit>IMD31</unit><unit>IMD32</unit><unit>IMD33</unit><unit>IMD34</unit><unit>IMD35</unit>
            <unit>IMD36</unit><unit>IMD37</unit><unit>IMD38</unit><unit>IMD39</unit><unit>IMD40</unit><unit>IMD41</unit><unit>IMD42</unit><unit>IMD43</unit>
            <unit>IMD44</unit><unit>IMD45</unit><unit>IMD46</unit><unit>IMD47</unit><unit>IMD48</unit><unit>IMD49</unit><unit>IMD50</unit><unit>IMD51</unit>
            <unit>IMD52</unit><unit>IMD53</unit><unit>IMD54</unit><unit>IMD55</unit><unit>IMD56</unit><unit>IMD57</unit><unit>IMD58</unit><unit>IMD59</unit>
            <unit>IMD60</unit><unit>IMD61</unit><unit>IMD62</unit><unit>IMD63</unit><unit>IMD64</unit><unit>IMD65</unit><unit>IMD66</unit><unit>IMD67</unit>
            <unit>IMD68</unit><unit>IMD69</unit><unit>IMD70</unit><unit>IMD71</unit><unit>IMD72</unit><unit>IMD73</unit><unit>IMD74</unit><unit>IMD75</unit>
            <unit>IMD76</unit><unit>IMD77</unit><unit>IMD79</unit><unit>IMD80</unit><unit>IMD81</unit><unit>IMD82</unit><unit>IMD83</unit><unit>IMD84</unit>
            <unit>IMD85</unit><unit>IMD86</unit><unit>IMD87</unit><unit>IMD88</unit><unit>IMD89</unit><unit>IMD90</unit><unit>IMD91</unit><unit>IMD92</unit>
            <unit>IMD93</unit><unit>IMD94</unit><unit>IME</unit><unit>IMT</unit><unit>INC</unit><unit>IOC</unit><unit>IOE</unit><unit>IOW</unit>
            <unit>IPM</unit><unit>IPO</unit><unit>IPO01</unit><unit>IPO02</unit><unit>IPO03</unit><unit>IPO04</unit><unit>IPO05</unit><unit>IPO06</unit>
            <unit>IPO07</unit><unit>IPO08</unit><unit>IPO09</unit><unit>IPO10</unit><unit>IPO11</unit><unit>IPO12</unit><unit>IPO13</unit><unit>IPO14</unit>
            <unit>IPO15</unit><unit>IPO16</unit><unit>IPO17</unit><unit>IPO19</unit><unit>IRA</unit><unit>IRA01</unit><unit>IRA02</unit><unit>IRA03</unit>
            <unit>IRA04</unit><unit>IRA05</unit><unit>IRA06</unit><unit>IRA07</unit><unit>IRA08</unit><unit>IRA09</unit><unit>IRA10</unit><unit>IRA11</unit>
            <unit>IRA12</unit><unit>IRA13</unit><unit>IRA14</unit><unit>IRA15</unit><unit>IRA16</unit><unit>IRA17</unit><unit>IRA18</unit><unit>IRA19</unit>
            <unit>IRA20</unit><unit>IRA21</unit><unit>IRA22</unit><unit>IRA23</unit><unit>IRA24</unit><unit>IRA25</unit><unit>IRA26</unit><unit>IRA27</unit>
            <unit>IRA28</unit><unit>IRA29</unit><unit>IRA30</unit><unit>IRA31</unit><unit>IRA32</unit><unit>IRA33</unit><unit>IRA34</unit><unit>IRA35</unit>
            <unit>IRA37</unit><unit>IRA38</unit><unit>IRA40</unit><unit>IRA41</unit><unit>IRA42</unit><unit>IRA43</unit><unit>IRA48</unit><unit>IRA49</unit>
            <unit>IRA50</unit><unit>IRA51</unit><unit>IRA52</unit><unit>IRA53</unit><unit>IRA54</unit><unit>IRA55</unit><unit>IRA56</unit><unit>IRA57</unit>
            <unit>IRA58</unit><unit>IRA59</unit><unit>IRA60</unit><unit>IRA61</unit><unit>IRA62</unit><unit>IRA63</unit><unit>IRA64</unit><unit>IRA65</unit>
            <unit>IRA66</unit><unit>IRC</unit><unit>ISE</unit><unit>ISE01</unit><unit>ISE02</unit><unit>ITA</unit><unit>ITA01</unit><unit>ITA02</unit>
            <unit>ITA03</unit><unit>ITE</unit><unit>ITE01</unit><unit>ITE02</unit><unit>ITE03</unit><unit>ITE04</unit><unit>ITE05</unit><unit>ITE06</unit>
            <unit>ITE07</unit><unit>ITE08</unit><unit>ITE09</unit><unit>ITE10</unit><unit>ITE11</unit><unit>ITE12</unit><unit>ITE13</unit><unit>ITE14</unit>
            <unit>ITE15</unit><unit>ITE16</unit><unit>ITE17</unit><unit>ITE18</unit><unit>ITE19</unit><unit>ITE20</unit><unit>ITE21</unit><unit>ITE22</unit>
            <unit>ITE23</unit><unit>ITE24</unit><unit>ITE25</unit><unit>ITE26</unit><unit>ITE27</unit><unit>ITE28</unit><unit>ITE29</unit><unit>ITE30</unit>
            <unit>ITE31</unit><unit>ITE32</unit><unit>ITE33</unit><unit>ITE34</unit><unit>ITE35</unit><unit>ITE36</unit><unit>ITE37</unit><unit>ITE38</unit>
            <unit>ITE39</unit><unit>ITE40</unit><unit>ITE41</unit><unit>ITE42</unit><unit>ITE43</unit><unit>ITE45</unit><unit>ITE46</unit><unit>ITE47</unit>
            <unit>ITE48</unit><unit>ITE49</unit><unit>ITE50</unit><unit>ITE51</unit><unit>ITE52</unit><unit>ITE53</unit><unit>ITE54</unit><unit>ITE55</unit>
            <unit>ITE56</unit><unit>ITE57</unit><unit>ITE58</unit><unit>ITE59</unit><unit>ITE60</unit><unit>ITE61</unit><unit>ITE62</unit><unit>ITE63</unit>
            <unit>ITE64</unit><unit>ITE65</unit><unit>ITE66</unit><unit>ITE67</unit><unit>ITE68</unit><unit>ITE69</unit><unit>ITE70</unit><unit>ITE71</unit>
            <unit>ITE72</unit><unit>ITE73</unit><unit>ITE74</unit><unit>ITE75</unit><unit>ITE76</unit><unit>ITE77</unit><unit>ITE78</unit><unit>ITE79</unit>
            <unit>ITE80</unit><unit>ITE81</unit><unit>ITE82</unit><unit>ITE83</unit><unit>ITE84</unit><unit>ITE85</unit><unit>ITE86</unit><unit>ITE87</unit>
            <unit>JTC</unit><unit>JTC02</unit><unit>JTC03</unit><unit>JTC05</unit><unit>JTC07</unit><unit>JTC08</unit><unit>JTC10</unit><unit>JTC11</unit>
            <unit>JTC12</unit><unit>JTC13</unit><unit>JTC14</unit><unit>JTC15</unit><unit>JTC16</unit><unit>JTC17</unit><unit>JTC19</unit><unit>JTC21</unit>
            <unit>JTC26</unit><unit>JTC27</unit><unit>JTC30</unit><unit>JTC31</unit><unit>JTC33</unit><unit>JTC35</unit><unit>JTC36</unit><unit>JTC37</unit>
            <unit>JTC40</unit><unit>JTC41</unit><unit>JTC42</unit><unit>JTC43</unit><unit>JTC44</unit><unit>JTC45</unit><unit>JTC51</unit><unit>JTC52</unit>
            <unit>JTC53</unit><unit>JTC54</unit><unit>JTC55</unit><unit>JTC57</unit><unit>JTC59</unit><unit>JTC60</unit><unit>JTC63</unit><unit>JTC64</unit>
            <unit>JTC65</unit><unit>JTC66</unit><unit>JTC67</unit><unit>JTC68</unit><unit>JTC69</unit><unit>JTC70</unit><unit>JUD</unit><unit>JUD01</unit>
            <unit>JUD02</unit><unit>JUD03</unit><unit>LAW</unit><unit>LAW01</unit><unit>LAW02</unit><unit>LAW04</unit><unit>LAW05</unit><unit>LAW06</unit>
            <unit>LAW07</unit><unit>LAW08</unit><unit>LAW09</unit><unit>LAW10</unit><unit>LAW13</unit><unit>LAW14</unit><unit>LAW15</unit><unit>LGM</unit>
            <unit>LTA</unit><unit>LTA01</unit><unit>MAC</unit><unit>MAS</unit><unit>MAS02</unit><unit>MAS03</unit><unit>MAS04</unit><unit>MAS05</unit>
            <unit>MAS07</unit><unit>MAS08</unit><unit>MAS09</unit><unit>MAS10</unit><unit>MAS11</unit><unit>MAS12</unit><unit>MAS13</unit><unit>MAS14</unit>
            <unit>MAS15</unit><unit>MAS16</unit><unit>MAS18</unit><unit>MAS19</unit><unit>MAS21</unit><unit>MAS22</unit><unit>MAS23</unit><unit>MAS24</unit>
            <unit>MAS25</unit><unit>MAS30</unit><unit>MAS31</unit><unit>MAS32</unit><unit>MAS33</unit><unit>MAS35</unit><unit>MAS36</unit><unit>MAS37</unit>
            <unit>MAS38</unit><unit>MAS39</unit><unit>MAS40</unit><unit>MAS41</unit><unit>MAS42</unit><unit>MAS43</unit><unit>MAS44</unit><unit>MAS45</unit>
            <unit>MCB</unit><unit>MCD</unit><unit>MCD01</unit><unit>MCD03</unit><unit>MCD04</unit><unit>MCD05</unit><unit>MCD06</unit><unit>MCD07</unit>
            <unit>MCD08</unit><unit>MCD09</unit><unit>MCD10</unit><unit>MCD12</unit><unit>MCD13</unit><unit>MCD14</unit><unit>MCD15</unit><unit>MCD16</unit>
            <unit>MCD17</unit><unit>MCD18</unit><unit>MCD19</unit><unit>MCD21</unit><unit>MCD23</unit><unit>MCD24</unit><unit>MEL</unit><unit>MFA</unit>
            <unit>MFA01</unit><unit>MFG</unit><unit>MHA</unit><unit>MHA01</unit><unit>MHA05</unit><unit>MHA06</unit><unit>MHA07</unit><unit>MHA09</unit>
            <unit>MHA10</unit><unit>MHA11</unit><unit>MHA12</unit><unit>MHA13</unit><unit>MHA14</unit><unit>MHA15</unit><unit>MHA16</unit><unit>MHA17</unit>
            <unit>MHA18</unit><unit>MHA19</unit><unit>MHA20</unit><unit>MHA21</unit><unit>MHA22</unit><unit>MHA23</unit><unit>MHA24</unit><unit>MHA25</unit>
            <unit>MHA26</unit><unit>MHA27</unit><unit>MHA28</unit><unit>MHA29</unit><unit>MHA30</unit><unit>MHA31</unit><unit>MHA32</unit><unit>MHA33</unit>
            <unit>MHA34</unit><unit>MHA35</unit><unit>MHA36</unit><unit>MHA37</unit><unit>MHA39</unit><unit>MHA41</unit><unit>MHA42</unit><unit>MHA43</unit>
            <unit>MHA44</unit><unit>MHA45</unit><unit>MHA46</unit><unit>MHA47</unit><unit>MHA48</unit><unit>MHA49</unit><unit>MHA50</unit><unit>MHA51</unit>
            <unit>MHA52</unit><unit>MHA54</unit><unit>MHA55</unit><unit>MHA56</unit><unit>MHA57</unit><unit>MHD01</unit><unit>MND</unit><unit>MND01</unit>
            <unit>MOC</unit><unit>MOC01</unit><unit>MOD</unit><unit>MOE</unit><unit>MOE01</unit><unit>MOE03</unit><unit>MOE06</unit><unit>MOE07</unit>
            <unit>MOE08</unit><unit>MOE09</unit><unit>MOE10</unit><unit>MOE11</unit><unit>MOE12</unit><unit>MOE13</unit><unit>MOE14</unit><unit>MOE15</unit>
            <unit>MOE16</unit><unit>MOE17</unit><unit>MOE18</unit><unit>MOE19</unit><unit>MOE20</unit><unit>MOE21</unit><unit>MOE22</unit><unit>MOE23</unit>
            <unit>MOE32</unit><unit>MOF</unit><unit>MOF01</unit><unit>MOF03</unit><unit>MOF05</unit><unit>MOF09</unit><unit>MOF17</unit><unit>MOF18</unit>
            <unit>MOF20</unit><unit>MOF21</unit><unit>MOF22</unit><unit>MOH</unit><unit>MOH01</unit><unit>MOH02</unit><unit>MOH03</unit><unit>MOH04</unit>
            <unit>MOH05</unit><unit>MOH06</unit><unit>MOH07</unit><unit>MOH08</unit><unit>MOH09</unit><unit>MOH10</unit><unit>MOH11</unit><unit>MOM</unit>
            <unit>MOM01</unit><unit>MOM02</unit><unit>MOM03</unit><unit>MOM04</unit><unit>MOM06</unit><unit>MOM07</unit><unit>MOM08</unit><unit>MOM09</unit>
            <unit>MOM10</unit><unit>MOM11</unit><unit>MOM14</unit><unit>MOM15</unit><unit>MOM16</unit><unit>MOM18</unit><unit>MOM20</unit><unit>MOM21</unit>
            <unit>MOM22</unit><unit>MOM23</unit><unit>MOM24</unit><unit>MPA</unit><unit>MPA01</unit><unit>MPA02</unit><unit>MPA03</unit><unit>MPA04</unit>
            <unit>MPA05</unit><unit>MPA06</unit><unit>MPA07</unit><unit>MPA08</unit><unit>MPA09</unit><unit>MPA10</unit><unit>MPA11</unit><unit>MPA12</unit>
            <unit>MPA13</unit><unit>MPA14</unit><unit>MPA15</unit><unit>MPA16</unit><unit>MPA17</unit><unit>MPA18</unit><unit>MPA19</unit><unit>MPA20</unit>
            <unit>MPA21</unit><unit>MPA22</unit><unit>MPA23</unit><unit>MPA24</unit><unit>MPA25</unit><unit>MPA26</unit><unit>MPA27</unit><unit>MPA28</unit>
            <unit>MPA29</unit><unit>MPA30</unit><unit>MPA31</unit><unit>MPA32</unit><unit>MPA33</unit><unit>MPA34</unit><unit>MPA35</unit><unit>MPA36</unit>
            <unit>MPA37</unit><unit>MPA38</unit><unit>MPA39</unit><unit>MPA40</unit><unit>MPA41</unit><unit>MPA42</unit><unit>MPO</unit><unit>MRE</unit>
            <unit>MSI</unit><unit>MTC</unit><unit>MTI</unit><unit>MTI01</unit><unit>MTI03</unit><unit>MTI04</unit><unit>MUI</unit><unit>MUI01</unit>
            <unit>MUI02</unit><unit>MUI03</unit><unit>MUI04</unit><unit>MUI05</unit><unit>MUI06</unit><unit>MUI07</unit><unit>MUI08</unit><unit>MUI09</unit>
            <unit>MUI10</unit><unit>MUI11</unit><unit>MUI12</unit><unit>MUI13</unit><unit>MUI14</unit><unit>MUI15</unit><unit>MUI16</unit><unit>MUI17</unit>
            <unit>MUI18</unit><unit>MUI19</unit><unit>MUI20</unit><unit>MUI21</unit><unit>MUI22</unit><unit>MUI23</unit><unit>MUI24</unit><unit>MUI25</unit>
            <unit>MUI26</unit><unit>MUI27</unit><unit>MUI28</unit><unit>MUI29</unit><unit>MUI30</unit><unit>MUI31</unit><unit>MUI32</unit><unit>MUI33</unit>
            <unit>MUI34</unit><unit>MUI35</unit><unit>MUI36</unit><unit>MUI37</unit><unit>MUI38</unit><unit>MUI39</unit><unit>MUI40</unit><unit>MUI41</unit>
            <unit>MUI42</unit><unit>MUI43</unit><unit>MUI44</unit><unit>MUI45</unit><unit>MUI46</unit><unit>MUI47</unit><unit>NAC</unit><unit>NAC01</unit>
            <unit>NAC02</unit><unit>NAC03</unit><unit>NAC04</unit><unit>NAC05</unit><unit>NAC06</unit><unit>NAC07</unit><unit>NAC08</unit><unit>NAC09</unit>
            <unit>NAC10</unit><unit>NAC11</unit><unit>NAC12</unit><unit>NAC13</unit><unit>NAC14</unit><unit>NAC15</unit><unit>NAC17</unit><unit>NAC18</unit>
            <unit>NAC19</unit><unit>NAC20</unit><unit>NAC21</unit><unit>NAC22</unit><unit>NAC23</unit><unit>NAC24</unit><unit>NAC25</unit><unit>NAC26</unit>
            <unit>NAC27</unit><unit>NAC28</unit><unit>NBL</unit><unit>NCS</unit><unit>NCS01</unit><unit>NCS02</unit><unit>NCS03</unit><unit>NCS04</unit>
            <unit>NCS05</unit><unit>NCS06</unit><unit>NCS07</unit><unit>NCS08</unit><unit>NCS09</unit><unit>NCS10</unit><unit>NCS11</unit><unit>NCS12</unit>
            <unit>NCS13</unit><unit>NCS14</unit><unit>NCS15</unit><unit>NCS16</unit><unit>NCS17</unit><unit>NCS18</unit><unit>NCS19</unit><unit>NCS20</unit>
            <unit>NCS21</unit><unit>NCS22</unit><unit>NCS23</unit><unit>NCS24</unit><unit>NCS25</unit><unit>NCS26</unit><unit>NCS27</unit><unit>NCS28</unit>
            <unit>NCS29</unit><unit>NCS30</unit><unit>NCS31</unit><unit>NCS32</unit><unit>NCS33</unit><unit>NDE</unit><unit>NEA</unit><unit>NEA01</unit>
            <unit>NEA02</unit><unit>NEA03</unit><unit>NEA04</unit><unit>NEA05</unit><unit>NEA06</unit><unit>NEA07</unit><unit>NEA08</unit><unit>NEA09</unit>
            <unit>NEA10</unit><unit>NEA11</unit><unit>NEA12</unit><unit>NEA13</unit><unit>NEA14</unit><unit>NEA15</unit><unit>NEA16</unit><unit>NEA17</unit>
            <unit>NEA18</unit><unit>NEA19</unit><unit>NEA20</unit><unit>NEA21</unit><unit>NEA22</unit><unit>NEA23</unit><unit>NEA24</unit><unit>NEA25</unit>
            <unit>NEA26</unit><unit>NEA27</unit><unit>NEA28</unit><unit>NEA29</unit><unit>NEA30</unit><unit>NEA31</unit><unit>NEA32</unit><unit>NEA33</unit>
            <unit>NEA34</unit><unit>NEA35</unit><unit>NEA36</unit><unit>NEA37</unit><unit>NEA38</unit><unit>NHB</unit><unit>NHB01</unit><unit>NHB02</unit>
            <unit>NHB03</unit><unit>NHB04</unit><unit>NHB05</unit><unit>NHB06</unit><unit>NHB07</unit><unit>NHB08</unit><unit>NHB09</unit><unit>NHB10</unit>
            <unit>NHB11</unit><unit>NHB12</unit><unit>NHB13</unit><unit>NHB14</unit><unit>NHB15</unit><unit>NHB16</unit><unit>NHB17</unit><unit>NHB18</unit>
            <unit>NHB19</unit><unit>NHB20</unit><unit>NHB21</unit><unit>NHB22</unit><unit>NHB23</unit><unit>NHB24</unit><unit>NHB25</unit><unit>NHB26</unit>
            <unit>NHB27</unit><unit>NHB28</unit><unit>NHB29</unit><unit>NHB30</unit><unit>NHB31</unit><unit>NHB32</unit><unit>NHB33</unit><unit>NLB</unit>
            <unit>NLB01</unit><unit>NLB02</unit><unit>NLB03</unit><unit>NLB04</unit><unit>NLB05</unit><unit>NLB06</unit><unit>NLB07</unit><unit>NLB08</unit>
            <unit>NLB09</unit><unit>NLB10</unit><unit>NLB11</unit><unit>NLB12</unit><unit>NLB13</unit><unit>NLB14</unit><unit>NLB15</unit><unit>NLB16</unit>
            <unit>NLB17</unit><unit>NLB18</unit><unit>NLB19</unit><unit>NLB20</unit><unit>NLB21</unit><unit>NLB22</unit><unit>NLB23</unit><unit>NLB24</unit>
            <unit>NLB25</unit><unit>NLB26</unit><unit>NMC</unit><unit>NPB</unit><unit>NPBA0</unit><unit>NPBA1</unit><unit>NPBA2</unit><unit>NPBA3</unit>
            <unit>NPBA4</unit><unit>NPBA5</unit><unit>NPBA6</unit><unit>NPBA7</unit><unit>NPBA8</unit><unit>NPBA9</unit><unit>NPBB0</unit><unit>NPBB1</unit>
            <unit>NPBB2</unit><unit>NPBB3</unit><unit>NPBB4</unit><unit>NPBB5</unit><unit>NPBB6</unit><unit>NPBB7</unit><unit>NPBB8</unit><unit>NPBB9</unit>
            <unit>NPBC0</unit><unit>NPBC1</unit><unit>NPBC2</unit><unit>NPBC3</unit><unit>NPBC4</unit><unit>NPBC5</unit><unit>NPBC6</unit><unit>NPBC7</unit>
            <unit>NPBC8</unit><unit>NPBC9</unit><unit>NPBD0</unit><unit>NPBD1</unit><unit>NPBD2</unit><unit>NPBD3</unit><unit>NPBD4</unit><unit>NPBD5</unit>
            <unit>NPBD6</unit><unit>NPBD7</unit><unit>NPBD8</unit><unit>NPBD9</unit><unit>NPBE0</unit><unit>NPBE1</unit><unit>NPBE2</unit><unit>NPBE3</unit>
            <unit>NPBE4</unit><unit>NPBE5</unit><unit>NPBE6</unit><unit>NPBE7</unit><unit>NPBE8</unit><unit>NPBE9</unit><unit>NPBF0</unit><unit>NPBF1</unit>
            <unit>NPBF2</unit><unit>NPBF3</unit><unit>NPBF4</unit><unit>NPBF5</unit><unit>NPBF6</unit><unit>NPBF7</unit><unit>NPBF8</unit><unit>NPBF9</unit>
            <unit>NPBG0</unit><unit>NPBG1</unit><unit>NPBG2</unit><unit>NPBG3</unit><unit>NPBG4</unit><unit>NPBG5</unit><unit>NPBG6</unit><unit>NPBG7</unit>
            <unit>NPBG8</unit><unit>NPBG9</unit><unit>NPBH0</unit><unit>NPBH1</unit><unit>NPBH2</unit><unit>NPBH3</unit><unit>NPBH4</unit><unit>NPBH5</unit>
            <unit>NPBH6</unit><unit>NPBH7</unit><unit>NPBH8</unit><unit>NPBH9</unit><unit>NPBI0</unit><unit>NPBI1</unit><unit>NPBI2</unit><unit>NPBI3</unit>
            <unit>NPBI4</unit><unit>NPBI5</unit><unit>NPBI6</unit><unit>NPBI7</unit><unit>NPBI8</unit><unit>NPBI9</unit><unit>NPBJ0</unit><unit>NPBJ1</unit>
            <unit>NPBJ2</unit><unit>NPBJ3</unit><unit>NPBJ4</unit><unit>NPBJ5</unit><unit>NPBJ6</unit><unit>NPBJ7</unit><unit>NPBJ8</unit><unit>NPBJ9</unit>
            <unit>NPBK0</unit><unit>NPBK1</unit><unit>NPBK2</unit><unit>NPBK3</unit><unit>NPBK4</unit><unit>NPBK5</unit><unit>NPBK6</unit><unit>NPBK7</unit>
            <unit>NPBK8</unit><unit>NPBK9</unit><unit>NPBL0</unit><unit>NPBL1</unit><unit>NPBL2</unit><unit>NPBL3</unit><unit>NPBL4</unit><unit>NPBL5</unit>
            <unit>NPBL6</unit><unit>NPBL7</unit><unit>NPBL8</unit><unit>NPBL9</unit><unit>NPBM0</unit><unit>NPBM1</unit><unit>NPBM2</unit><unit>NPBM3</unit>
            <unit>NPBM4</unit><unit>NPBM5</unit><unit>NPBM6</unit><unit>NPBM7</unit><unit>NPBM8</unit><unit>NPBM9</unit><unit>NPBN0</unit><unit>NPBN1</unit>
            <unit>NPBN2</unit><unit>NPBN3</unit><unit>NPBN4</unit><unit>NPBN5</unit><unit>NPBN6</unit><unit>NPBN7</unit><unit>NPBN8</unit><unit>NPBN9</unit>
            <unit>NPBO0</unit><unit>NPBO1</unit><unit>NPBO2</unit><unit>NPBO3</unit><unit>NPBO4</unit><unit>NPBO5</unit><unit>NPBO6</unit><unit>NPBO7</unit>
            <unit>NPBO8</unit><unit>NPBO9</unit><unit>NPBP0</unit><unit>NPBP1</unit><unit>NPBP2</unit><unit>NPBP3</unit><unit>NPBP4</unit><unit>NPBP5</unit>
            <unit>NPBP6</unit><unit>NPBP7</unit><unit>NPBP8</unit><unit>NPBP9</unit><unit>NPBQ0</unit><unit>NPBQ1</unit><unit>NPBQ2</unit><unit>NPBQ3</unit>
            <unit>NPBQ4</unit><unit>NPBQ5</unit><unit>NPBQ6</unit><unit>NPBQ7</unit><unit>NPBQ8</unit><unit>NPBQ9</unit><unit>NPBR1</unit><unit>NPBR2</unit>
            <unit>NPBR3</unit><unit>NPBR4</unit><unit>NPBR5</unit><unit>NPBR6</unit><unit>NPBR7</unit><unit>NPBR8</unit><unit>NPBR9</unit><unit>NPBS0</unit>
            <unit>NPBS1</unit><unit>NPBS2</unit><unit>NPBS3</unit><unit>NPBS4</unit><unit>NPBS5</unit><unit>NPBS6</unit><unit>NPBS7</unit><unit>NPBS8</unit>
            <unit>NPBS9</unit><unit>NPBT0</unit><unit>NPBT1</unit><unit>NPBT2</unit><unit>NPBT3</unit><unit>NPBT4</unit><unit>NPBT5</unit><unit>NPBT6</unit>
            <unit>NPBT7</unit><unit>NPBT8</unit><unit>NPBT9</unit><unit>NPBU0</unit><unit>NPBU1</unit><unit>NPO</unit><unit>NPO01</unit><unit>NPO02</unit>
            <unit>NPO03</unit><unit>NPO04</unit><unit>NPO05</unit><unit>NPO06</unit><unit>NPO07</unit><unit>NPO08</unit><unit>NPO09</unit><unit>NPO10</unit>
            <unit>NPO11</unit><unit>NPO12</unit><unit>NPO13</unit><unit>NPO14</unit><unit>NPO15</unit><unit>NPO17</unit><unit>NPO18</unit><unit>NPO19</unit>
            <unit>NPO20</unit><unit>NPO21</unit><unit>NPO22</unit><unit>NPO23</unit><unit>NPO24</unit><unit>NPO25</unit><unit>NPO27</unit><unit>NPO28</unit>
            <unit>NPO29</unit><unit>NPT</unit><unit>NYP</unit><unit>NYP01</unit><unit>NYP02</unit><unit>NYP03</unit><unit>NYP04</unit><unit>NYP06</unit>
            <unit>NYP07</unit><unit>NYP08</unit><unit>NYP09</unit><unit>NYP10</unit><unit>NYP11</unit><unit>NYP12</unit><unit>NYP13</unit><unit>NYP14</unit>
            <unit>NYP16</unit><unit>NYP17</unit><unit>NYP18</unit><unit>NYP19</unit><unit>NYP20</unit><unit>NYP21</unit><unit>NYP22</unit><unit>NYP23</unit>
            <unit>NYP24</unit><unit>NYP25</unit><unit>NYP26</unit><unit>NYP27</unit><unit>NYP28</unit><unit>NYP30</unit><unit>NYP31</unit><unit>NYP32</unit>
            <unit>NYP33</unit><unit>NYP34</unit><unit>NYP36</unit><unit>NYP37</unit><unit>OAS</unit><unit>ONS</unit><unit>OPS</unit><unit>OSS</unit>
            <unit>PAR</unit><unit>PAR01</unit><unit>PAS</unit><unit>PAS01</unit><unit>PAS02</unit><unit>PAS03</unit><unit>PAS04</unit><unit>PAS05</unit>
            <unit>PAS06</unit><unit>PAS07</unit><unit>PAS08</unit><unit>PAS09</unit><unit>PAS10</unit><unit>PAS12</unit><unit>PAS13</unit><unit>PAS14</unit>
            <unit>PAS15</unit><unit>PAS18</unit><unit>PAS20</unit><unit>PAS21</unit><unit>PAS22</unit><unit>PAS23</unit><unit>PAS24</unit><unit>PAS25</unit>
            <unit>PAS26</unit><unit>PAS27</unit><unit>PAS28</unit><unit>PAS29</unit><unit>PAS30</unit><unit>PAS32</unit><unit>PAS35</unit><unit>PAS39</unit>
            <unit>PAS40</unit><unit>PAS41</unit><unit>PAS43</unit><unit>PAS44</unit><unit>PAS45</unit><unit>PAS46</unit><unit>PAS47</unit><unit>PAS52</unit>
            <unit>PAS54</unit><unit>PAS55</unit><unit>PAS56</unit><unit>PAS57</unit><unit>PAS58</unit><unit>PAS59</unit><unit>PAS60</unit><unit>PAS61</unit>
            <unit>PAS62</unit><unit>PAS63</unit><unit>PAS64</unit><unit>PAS65</unit><unit>PAS66</unit><unit>PAS67</unit><unit>PAS68</unit><unit>PAS69</unit>
            <unit>PAS70</unit><unit>PAS71</unit><unit>PAS72</unit><unit>PAS73</unit><unit>PAS74</unit><unit>PAS75</unit><unit>PAS76</unit><unit>PAS77</unit>
            <unit>PAS78</unit><unit>PAS79</unit><unit>PAS80</unit><unit>PAS81</unit><unit>PBS</unit><unit>PBS01</unit><unit>PBS02</unit><unit>PBS03</unit>
            <unit>PBS04</unit><unit>PBS05</unit><unit>PCO</unit><unit>PCO01</unit><unit>PCO02</unit><unit>PCO03</unit><unit>PEB</unit><unit>PEB01</unit>
            <unit>PFA</unit><unit>PFA01</unit><unit>PFM</unit><unit>PMO</unit><unit>PMO01</unit><unit>PMO02</unit><unit>PMO03</unit><unit>PMO04</unit>
            <unit>PMO09</unit><unit>PMO10</unit><unit>PMO12</unit><unit>PMO13</unit><unit>PMO15</unit><unit>PMO16</unit><unit>PMO17</unit><unit>PMO19</unit>
            <unit>PMO20</unit><unit>PMO21</unit><unit>PMO25</unit><unit>PMO27</unit><unit>PMO28</unit><unit>PMO29</unit><unit>PTC</unit><unit>PTC01</unit>
            <unit>PUB</unit><unit>PUB01</unit><unit>PUB02</unit><unit>PUB03</unit><unit>PUB04</unit><unit>PUB05</unit><unit>PUB06</unit><unit>PUB07</unit>
            <unit>PUB08</unit><unit>PUB09</unit><unit>PUB10</unit><unit>PUB11</unit><unit>PUB12</unit><unit>PUB13</unit><unit>PUB14</unit><unit>PUB15</unit>
            <unit>PUB16</unit><unit>PUB17</unit><unit>PUB18</unit><unit>PUB19</unit><unit>PUB20</unit><unit>PUB21</unit><unit>PUB22</unit><unit>PUB23</unit>
            <unit>PUB24</unit><unit>PUB25</unit><unit>PUB26</unit><unit>PUB27</unit><unit>PUB28</unit><unit>PUB29</unit><unit>PUB30</unit><unit>PUB31</unit>
            <unit>PUB32</unit><unit>PUB33</unit><unit>PUB34</unit><unit>PUB35</unit><unit>PUB36</unit><unit>RDF</unit><unit>RES</unit><unit>RIS</unit>
            <unit>RPO</unit><unit>RPO02</unit><unit>RPO03</unit><unit>RPO05</unit><unit>RPO06</unit><unit>RPO07</unit><unit>RPO08</unit><unit>RPO09</unit>
            <unit>RPO10</unit><unit>RPO11</unit><unit>RPO12</unit><unit>RPO13</unit><unit>RPO14</unit><unit>RPO15</unit><unit>RPO16</unit><unit>RPO17</unit>
            <unit>RPO18</unit><unit>RPO19</unit><unit>RPO20</unit><unit>RPO21</unit><unit>RPO23</unit><unit>RPO24</unit><unit>RPO25</unit><unit>RPO26</unit>
            <unit>RPO27</unit><unit>RPO29</unit><unit>RPO30</unit><unit>RPO31</unit><unit>RPO32</unit><unit>RPO34</unit><unit>RPO35</unit><unit>RPO37</unit>
            <unit>RPO38</unit><unit>RPO40</unit><unit>RPO41</unit><unit>RPS01</unit><unit>RSC</unit><unit>RTC</unit><unit>SCB</unit><unit>SCB01</unit>
            <unit>SCC</unit><unit>SCE</unit><unit>SCF01</unit><unit>SDC</unit><unit>SDC01</unit><unit>SDC02</unit><unit>SDC03</unit><unit>SDC04</unit>
            <unit>SDC05</unit><unit>SDC06</unit><unit>SDC07</unit><unit>SDC08</unit><unit>SDC09</unit><unit>SDC10</unit><unit>SDC11</unit><unit>SDC12</unit>
            <unit>SDC13</unit><unit>SDC14</unit><unit>SDC15</unit><unit>SDC16</unit><unit>SDC17</unit><unit>SDC18</unit><unit>SDC19</unit><unit>SDC20</unit>
            <unit>SDC21</unit><unit>SDC22</unit><unit>SDC23</unit><unit>SDC24</unit><unit>SDC25</unit><unit>SDC26</unit><unit>SDC27</unit><unit>SDC28</unit>
            <unit>SDC29</unit><unit>SDC30</unit><unit>SDC31</unit><unit>SDC32</unit><unit>SDC33</unit><unit>SDC34</unit><unit>SDC35</unit><unit>SDC36</unit>
            <unit>SDC37</unit><unit>SDC38</unit><unit>SDC39</unit><unit>SDC40</unit><unit>SDC41</unit><unit>SDC42</unit><unit>SDC43</unit><unit>SDC44</unit>
            <unit>SDC45</unit><unit>SDC46</unit><unit>SDC47</unit><unit>SDC48</unit><unit>SDC49</unit><unit>SDC50</unit><unit>SDC51</unit><unit>SDC52</unit>
            <unit>SDC53</unit><unit>SDC54</unit><unit>SDC55</unit><unit>SDC56</unit><unit>SDC57</unit><unit>SDC58</unit><unit>SDC59</unit><unit>SDC60</unit>
            <unit>SDC61</unit><unit>SDC62</unit><unit>SDC63</unit><unit>SDC64</unit><unit>SDC65</unit><unit>SDC66</unit><unit>SDC67</unit><unit>SDC68</unit>
            <unit>SDC69</unit><unit>SDC70</unit><unit>SDC71</unit><unit>SDC72</unit><unit>SDC73</unit><unit>SDC74</unit><unit>SDC75</unit><unit>SDC76</unit>
            <unit>SDC77</unit><unit>SDC78</unit><unit>SDC79</unit><unit>SEB</unit><unit>SEB01</unit><unit>SFA</unit><unit>SFA01</unit><unit>SFA02</unit>
            <unit>SFA03</unit><unit>SFA04</unit><unit>SFA05</unit><unit>SFA06</unit><unit>SFA07</unit><unit>SFA08</unit><unit>SFA09</unit><unit>SFA10</unit>
            <unit>SFA11</unit><unit>SFA12</unit><unit>SFA13</unit><unit>SFA14</unit><unit>SFA15</unit><unit>SFA16</unit><unit>SFA17</unit><unit>SFA18</unit>
            <unit>SFA19</unit><unit>SFA20</unit><unit>SFA21</unit><unit>SFA22</unit><unit>SFA23</unit><unit>SIG</unit><unit>SIG04</unit><unit>SLA</unit>
            <unit>SLA01</unit><unit>SLF</unit><unit>SLF01</unit><unit>SPO</unit><unit>SPO05</unit><unit>SPO06</unit><unit>SPO07</unit><unit>SPO09</unit>
            <unit>SPO12</unit><unit>SPO13</unit><unit>SPO15</unit><unit>SPO21</unit><unit>SPO24</unit><unit>SPO26</unit><unit>SPO27</unit><unit>SPO28</unit>
            <unit>SPO29</unit><unit>SPO30</unit><unit>SPO34</unit><unit>SPO35</unit><unit>SPO36</unit><unit>SPO40</unit><unit>SPO45</unit><unit>SPO47</unit>
            <unit>SPO50</unit><unit>SPO60</unit><unit>SPO66</unit><unit>SPO71</unit><unit>SPO75</unit><unit>SPO80</unit><unit>SPO85</unit><unit>SPO86</unit>
            <unit>SPO87</unit><unit>SPO89</unit><unit>SPO90</unit><unit>SPO92</unit><unit>SPO93</unit><unit>SPO94</unit><unit>SPO97</unit><unit>SPO98</unit>
            <unit>SRL</unit><unit>SSC</unit><unit>SSC01</unit><unit>SSC02</unit><unit>SSC03</unit><unit>SSC04</unit><unit>SSC06</unit><unit>SSC07</unit>
            <unit>SSC09</unit><unit>SSC10</unit><unit>SSC11</unit><unit>SSC12</unit><unit>SSC13</unit><unit>SSC14</unit><unit>SSC15</unit><unit>SSC16</unit>
            <unit>SSC18</unit><unit>SSC19</unit><unit>SSC20</unit><unit>SSC21</unit><unit>SSC22</unit><unit>SSC23</unit><unit>SSC24</unit><unit>SSC25</unit>
            <unit>SSC26</unit><unit>SSC27</unit><unit>SSC28</unit><unit>SSC29</unit><unit>SSC30</unit><unit>SSC31</unit><unit>SSC33</unit><unit>SSC34</unit>
            <unit>SSC35</unit><unit>SSC36</unit><unit>SSC37</unit><unit>SSC38</unit><unit>SSC39</unit><unit>SSC40</unit><unit>SSC41</unit><unit>SSC42</unit>
            <unit>SSC43</unit><unit>SSG</unit><unit>SSG01</unit><unit>SSG02</unit><unit>SSG03</unit><unit>SSG04</unit><unit>SSG05</unit><unit>SSG06</unit>
            <unit>SSG07</unit><unit>SSG09</unit><unit>SSG10</unit><unit>SSG11</unit><unit>SSG12</unit><unit>SSG13</unit><unit>SSG14</unit><unit>SSG15</unit>
            <unit>SSG16</unit><unit>SSG17</unit><unit>SSG18</unit><unit>SSG19</unit><unit>SSG20</unit><unit>SSG21</unit><unit>SSG22</unit><unit>SSG23</unit>
            <unit>SSG24</unit><unit>SSG25</unit><unit>SSG26</unit><unit>SSG27</unit><unit>SSG28</unit><unit>SSG29</unit><unit>SSG30</unit><unit>SSG31</unit>
            <unit>SSG32</unit><unit>SSG33</unit><unit>SSG34</unit><unit>SSG35</unit><unit>SSG36</unit><unit>SSG37</unit><unit>SSG38</unit><unit>SSG39</unit>
            <unit>SSI</unit><unit>STA</unit><unit>STB</unit><unit>STB01</unit><unit>STB02</unit><unit>STB03</unit><unit>STB04</unit><unit>STB05</unit>
            <unit>STB06</unit><unit>STB07</unit><unit>STB08</unit><unit>STB09</unit><unit>STB10</unit><unit>STB11</unit><unit>STB12</unit><unit>STB14</unit>
            <unit>STB15</unit><unit>STB16</unit><unit>STB17</unit><unit>STB18</unit><unit>STB19</unit><unit>STB20</unit><unit>STB21</unit><unit>STB22</unit>
            <unit>STB23</unit><unit>STB24</unit><unit>STB25</unit><unit>STB26</unit><unit>STB27</unit><unit>STB28</unit><unit>STB29</unit><unit>STB30</unit>
            <unit>STB31</unit><unit>STB32</unit><unit>STB33</unit><unit>STB34</unit><unit>STB35</unit><unit>STB38</unit><unit>STB39</unit><unit>STB40</unit>
            <unit>STB41</unit><unit>STB42</unit><unit>STB43</unit><unit>STB44</unit><unit>STB45</unit><unit>STB46</unit><unit>STB47</unit><unit>STB48</unit>
            <unit>STB49</unit><unit>STC</unit><unit>STR</unit><unit>STR01</unit><unit>TIC</unit><unit>TOT</unit><unit>TOT01</unit><unit>TPO</unit>
            <unit>TPO01</unit><unit>TPO02</unit><unit>TPO03</unit><unit>TPO04</unit><unit>TPO05</unit><unit>TPO07</unit><unit>TPO08</unit><unit>TPO09</unit>
            <unit>TPO10</unit><unit>TPO11</unit><unit>TPO12</unit><unit>TPO13</unit><unit>TPO14</unit><unit>TPO15</unit><unit>TPO16</unit><unit>TPO17</unit>
            <unit>TPO18</unit><unit>TPO19</unit><unit>TPO20</unit><unit>TPO21</unit><unit>TPO22</unit><unit>TPO23</unit><unit>TPO24</unit><unit>TPO25</unit>
            <unit>TPO26</unit><unit>TPO27</unit><unit>TPO28</unit><unit>TSS</unit><unit>URA</unit><unit>URA01</unit><unit>URA02</unit><unit>URA03</unit>
            <unit>URA04</unit><unit>URA05</unit><unit>URA06</unit><unit>URA07</unit><unit>URA08</unit><unit>URA09</unit><unit>URA10</unit><unit>URA11</unit>
            <unit>URA12</unit><unit>URA13</unit><unit>URA14</unit><unit>URA15</unit><unit>URA16</unit><unit>URA17</unit><unit>URA18</unit><unit>URA19</unit>
            <unit>URA20</unit><unit>URA21</unit><unit>URA22</unit><unit>URA23</unit><unit>URA24</unit><unit>URA25</unit><unit>URA26</unit><unit>URA28</unit>
            <unit>URA30</unit><unit>URA31</unit><unit>URA32</unit><unit>URA33</unit><unit>URA34</unit><unit>URA35</unit><unit>URA36</unit><unit>URA37</unit>
            <unit>URA38</unit><unit>URA39</unit><unit>URA40</unit><unit>URA41</unit><unit>URA42</unit><unit>URA43</unit><unit>URA44</unit><unit>URA45</unit>
            <unit>URA46</unit><unit>URA48</unit><unit>URA49</unit><unit>URA50</unit><unit>URA52</unit><unit>URA53</unit><unit>URA54</unit><unit>URA55</unit>
            <unit>URA56</unit><unit>URA57</unit><unit>URA58</unit><unit>URA59</unit><unit>URA60</unit><unit>URA61</unit><unit>URA62</unit><unit>URA63</unit>
            <unit>URA64</unit><unit>URA65</unit><unit>URA66</unit><unit>URA67</unit><unit>URA68</unit><unit>URA69</unit><unit>URA70</unit><unit>URA71</unit>
            <unit>URA72</unit><unit>URA73</unit><unit>URA74</unit><unit>UWF</unit><unit>WSG</unit><unit>WSG01</unit><unit>WSG02</unit><unit>WSG03</unit>
            <unit>WSG04</unit><unit>WSG05</unit><unit>WSG06</unit><unit>WSG07</unit><unit>WSG08</unit><unit>WSG09</unit><unit>WSG10</unit><unit>WSG11</unit>
            <unit>WSG12</unit><unit>WSG13</unit><unit>WSG14</unit><unit>WSG15</unit><unit>WSG16</unit><unit>WSG17</unit><unit>WSG18</unit><unit>WSG19</unit>
            <unit>WSG20</unit><unit>WSG21</unit><unit>WSG22</unit><unit>WSG23</unit><unit>WSG24</unit><unit>WSG25</unit><unit>WSG26</unit><unit>WSG27</unit>
            <unit>WSG28</unit><unit>WSG32</unit><unit>WSG34</unit><unit>WSG35</unit><unit>WSG36</unit><unit>WSG37</unit><unit>XDH</unit><unit>YRF</unit>
            <unit>YRF01</unit><unit>YRS</unit><unit>YRS01</unit>
        </units>
    </xsl:variable>

    <!-- 创建Business Unit查找索引 - O(1)查找性能，避免StackOverflow -->
    <xsl:key name="business-unit-lookup" match="unit" use="text()"/>

    <!-- 主模板 -->
    <xsl:template match="/">
        <svrl:schematron-output title="Singapore AGD B2G Advanced Ordering Validation Rules" 
                                schemaVersion="iso">
            <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" prefix="cbc"/>
            <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" prefix="cac"/>
            <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" prefix="ubl"/>
            <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" prefix="cn"/>

            <svrl:active-pattern id="SG-AGD-B2G-patterns" name="SG-AGD-B2G-patterns"/>
            <xsl:apply-templates select="/" mode="M1"/>
        </svrl:schematron-output>
    </xsl:template>

    <!-- 模式 M1: 发票文档级别验证 -->
    <xsl:template match="ubl:Invoice" priority="1000" mode="M1">
        <svrl:fired-rule context="ubl:Invoice"/>
        <xsl:call-template name="validate-agd-fields"/>
        <xsl:call-template name="validate-line-items"/>
    </xsl:template>

    <!-- 模式 M1: 贷项通知单文档级别验证 -->
    <xsl:template match="cn:CreditNote" priority="1000" mode="M1">
        <svrl:fired-rule context="cn:CreditNote"/>
        <xsl:call-template name="validate-agd-fields"/>
        <xsl:call-template name="validate-line-items"/>
    </xsl:template>


    <!-- ==================== -->
    <!-- AGD B2G 字段验证 -->
    <!-- ==================== -->
    
    <xsl:template name="validate-agd-fields">
        
        <!-- AGD-R-001: Business Unit (买方参考) 必填 - 最大5个字符，必须在批准的列表中 -->
        <xsl:choose>
            <xsl:when test="not(cbc:BuyerReference)">
                <svrl:failed-assert test="cbc:BuyerReference" 
                                   flag="fatal" id="AGD-R-001">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-001] Business Unit (BuyerReference) is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:when>
            <xsl:when test="string-length(cbc:BuyerReference) &gt; 5">
                <svrl:failed-assert test="string-length(cbc:BuyerReference) &lt;= 5" 
                                   flag="fatal" id="AGD-R-001">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-001] Business Unit (BuyerReference) must not exceed 5 characters.</svrl:text>
                </svrl:failed-assert>
            </xsl:when>
            <xsl:otherwise>
                <!-- Validate against approved Business Unit list -->
                <xsl:variable name="buyer-ref" select="normalize-space(cbc:BuyerReference)"/>
                <xsl:variable name="is-valid">
                    <xsl:call-template name="check-business-unit">
                        <xsl:with-param name="code" select="$buyer-ref"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="$is-valid = 'false'">
                    <svrl:failed-assert test="false()" 
                                       flag="fatal" id="AGD-R-001">
                        <xsl:attribute name="location">
                            <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                        </xsl:attribute>
                        <svrl:text>[AGD-R-001] Business Unit '<xsl:value-of select="$buyer-ref"/>' is not in the approved list. Please enquire with your client agency for the correct Business Unit code.</svrl:text>
                    </svrl:failed-assert>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-002: Attention To (联系人姓名) 必填 - 最大20个字符 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Name and 
                          string-length(cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Name) &lt;= 20"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Name" 
                                   flag="fatal" id="AGD-R-002">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-002] Attention To (Contact Name) is mandatory and must not exceed 20 characters.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-003: Invoice Number 必填 - 最大27个字符,不能包含空格 -->
        <xsl:choose>
            <xsl:when test="cbc:ID and string-length(cbc:ID) &lt;= 27 and not(contains(cbc:ID, ' '))"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:ID and string-length(cbc:ID) &lt;= 27 and not(contains(cbc:ID, ' '))" 
                                   flag="fatal" id="AGD-R-003">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-003] Invoice Number is mandatory, must not exceed 27 characters and cannot contain spaces.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>


        <!-- AGD-R-004: Invoice Date 必填 - 不能倒填超过7天或提前填写 -->
        <xsl:choose>
            <xsl:when test="cbc:IssueDate"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:IssueDate" flag="fatal" id="AGD-R-004">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-004] Invoice Date is mandatory and cannot be backdated by more than 7 calendar days or forward-dated.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-005: Vendor ID 必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID" 
                                   flag="fatal" id="AGD-R-005">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-005] Vendor ID is mandatory. Must be based on approved vendor record at Vendors@Gov.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-006: Email Address 必填 -->
        <xsl:choose>
            <xsl:when test="cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail" 
                                   flag="fatal" id="AGD-R-006">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-006] Supplier Email Address is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-007: Payment Terms 必填 -->
        <xsl:choose>
            <xsl:when test="cac:PaymentTerms/cbc:Note"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:PaymentTerms/cbc:Note" flag="fatal" id="AGD-R-007">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-007] Payment Terms is mandatory. Must be based on agreed payment terms with client agency.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>


        <!-- AGD-R-008: Currency 必填 -->
        <xsl:choose>
            <xsl:when test="cbc:DocumentCurrencyCode"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:DocumentCurrencyCode" flag="fatal" id="AGD-R-008">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-008] Currency (DocumentCurrencyCode) is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-009: Invoice Description 必填 - 最大254个字符 -->
        <xsl:choose>
            <xsl:when test="cbc:Note and string-length(cbc:Note) &lt;= 254"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:Note and string-length(cbc:Note) &lt;= 254" 
                                   flag="fatal" id="AGD-R-009">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-009] Invoice Description is mandatory and must not exceed 254 characters.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-010: Related Invoice ID - 贷项通知单必填,最大30个字符,不能包含空格 -->
        <xsl:if test="self::cn:CreditNote">
            <xsl:choose>
                <xsl:when test="cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID and 
                              string-length(cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID) &lt;= 30 and
                              not(contains(cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID, ' '))"/>
                <xsl:otherwise>
                    <svrl:failed-assert test="cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID" 
                                       flag="fatal" id="AGD-R-010">
                        <xsl:attribute name="location">
                            <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                        </xsl:attribute>
                        <svrl:text>[AGD-R-010] Related Invoice ID is mandatory for credit notes, must not exceed 30 characters and cannot contain spaces.</svrl:text>
                    </svrl:failed-assert>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

        <!-- AGD-R-011: Sub Total (Excluding GST) 必填 -->
        <xsl:choose>
            <xsl:when test="cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount" 
                                   flag="fatal" id="AGD-R-011">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-011] Sub Total (TaxExclusiveAmount) is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>


        <!-- AGD-R-012: Total GST Amount 必填 -->
        <xsl:choose>
            <xsl:when test="cac:TaxTotal/cbc:TaxAmount"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:TaxTotal/cbc:TaxAmount" flag="fatal" id="AGD-R-012">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-012] Total GST Amount is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-013: Freight Amount - 如果存在,必须是Charge且ChargeIndicator为true -->
        <xsl:if test="cac:AllowanceCharge/cbc:Amount">
            <xsl:choose>
                <xsl:when test="cac:AllowanceCharge/cbc:ChargeIndicator = 'true' and
                              cac:AllowanceCharge/cbc:AllowanceChargeReasonCode = 'FC'"/>
                <xsl:otherwise>
                    <svrl:failed-assert test="cac:AllowanceCharge/cbc:ChargeIndicator = 'true'" 
                                       flag="fatal" id="AGD-R-013">
                        <xsl:attribute name="location">
                            <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                        </xsl:attribute>
                        <svrl:text>[AGD-R-013] Freight must be billed as a charge (ChargeIndicator=true) with reason code 'FC' at invoice header level only.</svrl:text>
                    </svrl:failed-assert>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

    </xsl:template>

    <!-- ==================== -->
    <!-- 发票行项目验证 -->
    <!-- ==================== -->
    <xsl:template name="validate-line-items">
        
        <!-- AGD-R-020: 至少一个发票行 -->
        <xsl:choose>
            <xsl:when test="cac:InvoiceLine or cac:CreditNoteLine"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:InvoiceLine or cac:CreditNoteLine" 
                                   flag="fatal" id="AGD-R-020">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-020] At least one invoice/credit note line is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- 应用行级验证 -->
        <xsl:apply-templates select="cac:InvoiceLine | cac:CreditNoteLine" mode="line-validation"/>

    </xsl:template>


    <!-- 行级验证模板 -->
    <xsl:template match="cac:InvoiceLine | cac:CreditNoteLine" mode="line-validation">
        
        <!-- AGD-R-021: Invoice Line Number 必填 - 最大5个字符 -->
        <xsl:choose>
            <xsl:when test="cbc:ID and string-length(cbc:ID) &lt;= 5"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:ID and string-length(cbc:ID) &lt;= 5" 
                                   flag="fatal" id="AGD-R-021">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-021] Invoice Line Number is mandatory and must not exceed 5 characters.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-022: Invoice Line Description 必填 - 最大254个字符 -->
        <xsl:choose>
            <xsl:when test="cac:Item/cbc:Name and string-length(cac:Item/cbc:Name) &lt;= 254"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:Item/cbc:Name and string-length(cac:Item/cbc:Name) &lt;= 254" 
                                   flag="fatal" id="AGD-R-022">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-022] Invoice Line Description is mandatory and must not exceed 254 characters.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-023: Unit Price 必填 -->
        <xsl:choose>
            <xsl:when test="cac:Price/cbc:PriceAmount"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:Price/cbc:PriceAmount" flag="fatal" id="AGD-R-023">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-023] Unit Price for Invoice Line is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-024: Quantity 必填 -->
        <xsl:choose>
            <xsl:when test="cbc:InvoicedQuantity or cbc:CreditedQuantity"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:InvoicedQuantity or cbc:CreditedQuantity" 
                                   flag="fatal" id="AGD-R-024">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-024] Quantity for Invoice Line is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>


        <!-- AGD-R-025: Invoice Line Amount (Excludes GST) 必填 -->
        <xsl:choose>
            <xsl:when test="cbc:LineExtensionAmount"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cbc:LineExtensionAmount" flag="fatal" id="AGD-R-025">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-025] Invoice Line Amount (Excludes GST) is mandatory.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

        <!-- AGD-R-026: Invoice Line GST Treatment 必填 -->
        <xsl:choose>
            <xsl:when test="cac:Item/cac:ClassifiedTaxCategory/cbc:ID"/>
            <xsl:otherwise>
                <svrl:failed-assert test="cac:Item/cac:ClassifiedTaxCategory/cbc:ID" 
                                   flag="fatal" id="AGD-R-026">
                    <xsl:attribute name="location">
                        <xsl:apply-templates select="." mode="schematron-select-full-path"/>
                    </xsl:attribute>
                    <svrl:text>[AGD-R-026] Invoice Line GST Treatment is mandatory. All invoice lines must have the same treatment.</svrl:text>
                </svrl:failed-assert>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- 模式 M1: 默认模板 (无验证) -->
    <xsl:template match="text()" priority="-1" mode="M1"/>
    <xsl:template match="text()" priority="-1" mode="line-validation"/>
    
    <xsl:template match="@*|node()" priority="-2" mode="M1">
        <xsl:apply-templates select="@*|node()" mode="M1"/>
    </xsl:template>

    <xsl:template match="@*|node()" priority="-2" mode="line-validation">
        <xsl:apply-templates select="@*|node()" mode="line-validation"/>
    </xsl:template>



    <!-- 生成XPath位置信息 -->
    <xsl:template match="*" mode="schematron-select-full-path">
        <xsl:apply-templates select="." mode="schematron-get-full-path"/>
    </xsl:template>

    <xsl:template match="*" mode="schematron-get-full-path">
        <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
        <xsl:text>/</xsl:text>
        <xsl:choose>
            <xsl:when test="namespace-uri()=''">
                <xsl:value-of select="name()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>*:</xsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>[namespace-uri()='</xsl:text>
                <xsl:value-of select="namespace-uri()"/>
                <xsl:text>']</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="preceding" select="count(preceding-sibling::*[local-name()=local-name(current()) and namespace-uri() = namespace-uri(current())])"/>
        <xsl:text>[</xsl:text>
        <xsl:value-of select="1+ $preceding"/>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="@*" mode="schematron-get-full-path">
        <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
        <xsl:text>/@</xsl:text>
        <xsl:choose>
            <xsl:when test="namespace-uri()=''">
                <xsl:value-of select="name()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>*:</xsl:text>
                <xsl:value-of select="local-name()"/>
                <xsl:text>[namespace-uri()='</xsl:text>
                <xsl:value-of select="namespace-uri()"/>
                <xsl:text>']</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Check if Business Unit code is valid -->

    <!-- ==================== -->
    <!-- 优化后的Business Unit检查模板 -->
    <!-- 使用XSLT Key机制，避免超长or表达式导致的StackOverflow -->
    <!-- ==================== -->
    <xsl:template name="check-business-unit">
        <xsl:param name="code"/>
        <xsl:variable name="is-valid">
            <xsl:for-each select="$valid-business-units">
                <xsl:choose>
                    <xsl:when test="key('business-unit-lookup', $code)">true</xsl:when>
                    <xsl:otherwise>false</xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="$is-valid"/>
    </xsl:template>

</xsl:stylesheet>
