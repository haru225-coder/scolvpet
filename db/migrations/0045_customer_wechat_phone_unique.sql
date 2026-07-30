-- 一个有效手机号只能绑定一个有效微信 OpenID。历史解绑记录保留，换微信号
-- 必须先通过既有解绑接口撤销旧绑定后再重新授权，禁止静默接管账号。
BEGIN;

DO $$
BEGIN
  IF EXISTS (
    SELECT phone
    FROM customer_wechat_identity
    WHERE revoked_at IS NULL
    GROUP BY phone
    HAVING count(*) > 1
  ) THEN
    RAISE EXCEPTION 'cannot add active customer WeChat phone uniqueness: resolve duplicate active phone bindings first';
  END IF;
END $$;

CREATE UNIQUE INDEX ux_customer_wechat_identity_phone_active
  ON customer_wechat_identity (phone)
  WHERE revoked_at IS NULL;

COMMIT;
