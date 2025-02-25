let
  keys = [
    # zbioe
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyPvaFkKRd9oViOxWZMj97y5LtRNKyzNPHDBd4RWxaH/tvbSne7vHdp2HdDblum7V49gIW0epyfsePYpS77HSrCE66zeiTv7dzu8cNcBxJI4CeKMBpshY5KqD3K1qNgpiUMo5Dk8DYSQOEd/nz27JM9ae3DGi5IFXpWOJduoHcsxbzS9GfdVGO+XwwaCeNlLEsQnDsfZO7o32efHd+Y+kCk4q83ybodB3Jlv582uL7skx5OwU+0G6km+p+c2y0/fX1u6GXuHQLH9F+H3XOxmcu7bq/mTR2t0RS1OLNkmEtMKhaDt2wfK7eNpZ55GwcwbZmRlBNpoARH07Fi7MUg6vNmOBMvJr9Bqrq9rwc48XmPw+6sQ6YPeascNF06rdDrFCvW82tyQqSaCy+qBPMKLppn52upp6qmlL8cWB7TbQq7Yks9ILt5+5Net4cBDyNnI5TFTV6iQqlcPiT7gNhcK1S0Ut4iRTtm7GvbXPMSq5D8aqIRrSgBAWokxfIxWp6kk0= zbioe@pota"
  ];
in
{ config, pkgs, ... }:
{
  users.users = {
    root = {
      openssh = {
        authorizedKeys = {
          inherit keys;
        };
      };
    };
    zbioe = {
      hashedPassword = "$y$j9T$aUrSFZjFUIfKKBQ/C.bXY/$mS1UQvVwaBs6.777A7vnuMl3kGsWXpU0gY2VdtwdWi0";
      openssh = {
        authorizedKeys = {
          inherit keys;
        };
      };
      isNormalUser = true;
      uid = 1000;
      name = "zbioe";
      description = "zbioe user";
      extraGroups = [
        "wheel"
        "users"
        "input"
        "networkmanager"
        "audio"
        "video"
        "disk"
        "nixbld"
        "systemd-journal"
      ];
    };
  };
}
