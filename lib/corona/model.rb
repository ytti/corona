module Corona
  class Model
    def self.map sysDescr, sysObjectID
      case sysDescr
      when /Cisco Catalyst Operating System/i
        'catos'
      when /Cisco Controller/
        'aireos'
      when /IOS XR/
        'iosxr'
      when /NX-OS/
        'nxos'
      when /JUNOS/
        'junos'
      when /Arista Networks EOS/
        'eos'
      when /IronWare/
        'ironware'
      when /TiMOS/
        'timos'
      when /ExtremeXOS/
        'xos'
      when /Cisco Adaptive Security Appliance/
        'asa'
      when /Brocade Fibre Channel Switch/
        'fabricos'
      when /Brocade VDX/
        'nos'
      when /cisco/i, /Application Control Engine/i
        'ios'
      when /Force10 OS/
        'ftos'
      when /Versatile Routing Platform/
        'vrp'
      when /^NetScreen/, /^SSG-\d+/
        'screenos'
      when /^Summit/
        'xos'
      when /^Alcatel-Lucent \S+ [789]\./  #aos <7 is vxworks, >=7 is linux
        'aos7'
      when /^AOS-W/
        'aosw'
      when /^Alcatel-Lucent/
        'aos'
      when /\s+ACOS\s+/
        'acos'
      when /ProCurve/  # ProCurve OS does not seem to have name?
        'procurve'
      when /ASAM/
        'isam'
      when /^\d+[A-Z]\sEthernet Switch$/
        'powerconnect'
      else
        case sysObjectID
        when Regexp.new('^' + Regexp.quote('1.3.6.1.4.1.12356.'))
          'fortios'      # 1.3.6.1.4.1.12356.101.1.10004
        when Regexp.new('^' + Regexp.quote('1.3.6.1.4.1.6486.'))
          'aos'          # 1.3.6.1.4.1.6486.800.1.1.2.1.11.2.2
        when Regexp.new('^' + Regexp.quote('1.3.6.1.4.1.6027.'))
          'ftos'         # 1.3.6.1.4.1.6027.1.3.4
        when Regexp.new('^' + Regexp.quote('1.3.6.1.4.1.1588.'))
          'fabricos '    # 1.3.6.1.4.1.1588.2.1.1.1
        when Regexp.new('^' + Regexp.quote('1.3.6.1.4.1.3224.'))
          'screenos'     # 1.3.6.1.4.1.3224.1.51 (SSG) 1.16 (Netscreen 2k)
        when Regexp.new('^' + Regexp.quote('1.3.6.1.4.1.674.'))
          'powerconnect' # 1.3.6.1.4.1.674.10895.3031
        when Regexp.new('^' + Regexp.quote('1.3.6.1.4.1.22610.'))
          'acos'         # 1.3.6.1.4.1.22610.1.3.14
        when Regexp.new('^' + Regexp.quote('.1.3.6.1.4.1.637.'))
          'isam'         # 1.3.6.1.4.1.637.61.1
        when Regexp.new('^' + Regexp.quote('.1.3.6.1.4.1.2011.'))
          'vrp'          # 1.3.6.1.4.1.2011.2.224.67 (AR1220F)
        when Regexp.new('^' + Regexp.quote('.1.3.6.1.4.1.1588.'))
          'nos'          # 1.3.6.1.4.1.1588.2.2.1.1.1.5 (VDX)
        when Regexp.new('^' + Regexp.quote('.1.3.6.1.4.1.1916.'))
          'xos'          # 1.3.6.1.4.1.1916.2.76 (X450a-48t)
        when Regexp.new('^' + Regexp.quote('1.3.6.1.4.1.9.1.745'))
          'asa'          # 1.3.6.1.4.1.9.1.745
        else
          'unsupported'
        end
      end
    end
  end
end
