class PassiveRfid < ApplicationRecord
  def as_json(options = {})
    base = super(options)

    # Normalize antennas element keys to camelCase expected by the frontend
    normalized_antennas = (antennas || []).map do |a|
      {
        'antenna' => a['antenna'] || a[:antenna],
        'rxSensitivity' => a['rxSensitivity'] || a[:rxSensitivity] || a[:rx_sensitivity] || a['rx_sensitivity'],
        'txPower' => a['txPower'] || a[:txPower] || a[:tx_power] || a['tx_power'],
        'enabled' => a['enabled']
      }
    end

    base.merge(
      'hostName' => base.delete('host_name'),
      'antennaCount' => base.delete('antenna_count'),
      'gpiConfig' => base.delete('gpi_config'),
      'gpoConfig' => base.delete('gpo_config'),
      'edgeDevice' => base.delete('edge_device'),
      'antennas' => normalized_antennas
    )
  end
end


