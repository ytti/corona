module Corona
  class Model
    def self.map sysDescr
      case sysDescr
      when /Cisco Catalyst Operating System/i
        'catos'
      when /Cisco Controller/
        'aireos'
      when /IOS XR/
        'iosxr'
      when /NX-OS/
        'nxos'
      when /cisco/i, /Application Control Engine/i
        'ios'
      when /JUNOS/
        'junos'
      when /^NetScreen/, /^SSG-\d+/
        'screenos'
      when /Arista Networks EOS/
        'eos'
      when /IronWare/
        'ironware'
      when /^Summit/
        'xos'
      when /TiMOS/
        'timos'
      when /^Alcatel-Lucent \S+ [789]\./  #aos <7 is vxworks, >=7 is linux
        'aos7'
      when /^AOS-W/
        'aosw'
      when /^Alcatel-Lucent/
        'aos'
      when /^AX Series/
        'acos'
      when /ProCurve/  # ProCurve OS does not seem to have name?
        'procurve'
      when /^\d+[A-Z]\sEthernet Switch$/
        'powerconnect'
      end
    end
  end
end
