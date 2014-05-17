require "spec_helper"

require "rack/server"
require "net/http"
require "eventmachine"

require "faye"
require "faye/redis_delayed"

Faye::WebSocket.load_adapter('thin')

class TestServer
  def initialize
    @host = "localhost"
    @port = 9292

    faye.bind(:subscribe) do |client_id, channel|
      puts "SUBSCRIBE  #{client_id} #{channel}"
    end

    faye.bind(:publish) do |client_id, channel, data|
      puts "PUBLISH    #{client_id} #{channel}"
    end

    faye.bind(:handshake) do |client_id|
      puts "HANDSHAKE  #{client_id}"
    end

    faye.bind(:disconnect) do |client_id|
      puts "DISCONNECT #{client_id}"
    end
  end

  def url
    "http://#{@host}:#{@port}/faye"
  end

  def up?
    return false if @thread && @thread.join(0)

    res = Net::HTTP.start(@host, @port) { |http| http.get('/') }
    true
  rescue SystemCallError
    false
  end

  def boot
    puts "[server] Booting faye server..."
    @thread = Thread.new do
      Rack::Server.start(
        :Host => @host,
        :Port => @port,
        :app => faye,
        :environment => "production"
      )
    end

    Timeout.timeout(60) { @thread.join(0.1) until up? }
  rescue Timeout::Error
    raise "Rack application timed out during boot"
  else
    puts "[server] Faye server started"
    self
  end

  def shutdown
    puts "[server] Shutting down faye server"
    @thread.kill
    @thread.join
  end

  def faye
    @faye ||= Faye::RackAdapter.new(
      :mount   => '/',
      :timeout => 25,
      :engine  => {
        :type   => Faye::RedisDelayed,
        :namespace => redis_namespace,
        :expire => 30
      }
    )
  end

  def redis_namespace
    "faye-redis-delayed-test:#{rand(10000)}:"
  end

  def publish(channel, msg = {})
    faye.get_client.publish(channel, msg)
  end
end

class TestClient
  attr_reader :messages

  def initialize(url)
    @url = url
    @messages = []
    @client = Faye::Client.new(@url)
  end

  def subscribe(channel)
    @thread = Thread.new do
      EM.run do
        @client.subscribe(channel) do |message|
          puts "RECEIVE"
          @messages << message
        end
      end
    end
  end

  def disconnect
    @client.disconnect
    @thread.kill
    @thread.join
  end

end

describe Faye::RedisDelayed do
  let(:server) do
    TestServer.new
  end

  let(:client) do
    TestClient.new(server.url)
  end

  before do
    server.boot
  end

  after do
    client.disconnect
    sleep 2
    server.shutdown
  end

  specify "normal flow" do
    client.subscribe("/normal")
    sleep 2
    server.publish("/normal", {:text => "hello"})
    sleep 2
    expect(client.messages.size).to eq(1)
  end

  specify "delayed flow" do
    server.publish("/delayed", {:text => "hello delayed"})
    sleep 2
    client.subscribe("/delayed")
    sleep 2
    expect(client.messages.size).to eq(1)
  end
end
